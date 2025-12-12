resource "aws_sqs_queue" "karpenter_interruption_handler_sqs" {
  message_retention_seconds = 300
  name                      = "eks-${var.cluster.name}-karpenter"
  tags                      = var.tags
}


resource "helm_release" "karpenter_crd" {
  namespace        = "karpenter"
  create_namespace = true
  name             = "karpenter-crd"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter-crd"
  version          = var.karpenter_helm_version
  wait             = true
}

resource "helm_release" "karpenter" {
  depends_on = [helm_release.karpenter_crd]

  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_helm_version

  set = [
    {
      name  = "settings.clusterName"
      value = var.cluster.name
    },
    {
      name  = "settings.clusterEndpoint"
      value = var.cluster.endpoint
    },
    {
      name  = "settings.aws.defaultInstanceProfile"
      value = var.node_pod_execution_profile.name
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.karpenter_role.arn
    },
    {
      name  = "serviceAccount.automountToken"
      value = "true"
    },
    {
      name  = "settings.interruptionQueue"
      value = aws_sqs_queue.karpenter_interruption_handler_sqs.name
    },
    {
      name  = "controller.nodeSelector.role"
      value = "bootstrap"
    },
    {
      name  = "replicas"
      value = 1
    }
  ]
}


resource "kubernetes_manifest" "karpenter_nodepool" {
  depends_on = [helm_release.karpenter]

  computed_fields = ["spec.disruption", "spec.disruption.consolidatedAfter"]

  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "spot"
    }

    spec = {
      disruption = {
        consolidationPolicy = "WhenEmpty"
        consolidateAfter    = "1m"
      }
      limits = {
        cpu    = "80"
        memory = "120Gi"
      }
      template = {
        metadata = {
          labels = {
            self-managed-node = "true"
            node-type         = "spot"
            role              = "spot"
          }
        }
        spec = {
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "spot"
          }
          requirements = [
            { key = "karpenter.k8s.aws/instance-family", operator = "In", values = ["m5", "c5"] },
            { key = "karpenter.k8s.aws/instance-cpu", operator = "In", values = ["2", "4", "8"] },
            { key = "karpenter.k8s.aws/instance-memory", operator = "Gt", values = ["1"] },
            { key = "topology.kubernetes.io/zone", operator = "In", values = var.azs },
            { key = "kubernetes.io/arch", operator = "In", values = ["amd64"] },
            { key = "karpenter.sh/capacity-type", operator = "In", values = ["spot"] },
            { key = "kubernetes.io/os", operator = "In", values = ["linux"] }
          ]
        }
      }
    }
  }
}


resource "kubernetes_manifest" "karpenter_ec2nodeclass" {
  depends_on = [helm_release.karpenter]

  manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "spot"
    }
    spec = {
      instanceProfile = var.node_pod_execution_profile.name
      amiFamily       = "Bottlerocket"
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster.name
          }
        }
      ]
      amiSelectorTerms = [
        {
          id = var.ami_release
        }
      ]
      securityGroupSelectorTerms = [
        {
          tags = {
            "kubernetes.io/cluster/${var.cluster.name}" = "owned"
          }
        }
      ]
      tags = merge({
        Name                     = "${var.cluster.name}-node"
        "karpenter.sh/discovery" = var.cluster.name
        role                     = "spot"
      }, var.tags)
    }
  }
}
