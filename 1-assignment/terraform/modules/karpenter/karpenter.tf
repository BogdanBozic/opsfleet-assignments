resource "aws_sqs_queue" "karpenter_interruption_handler_sqs" {
  message_retention_seconds = 300
  name                      = "eks-${var.cluster.name}-karpenter"
  tags                      = var.tags
}
resource "helm_release" "karpenter" {

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
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.karpenter_role.arn
    },
    {
      name  = "settings.interruptionQueue"
      value = aws_sqs_queue.karpenter_interruption_handler_sqs.name
    },
    {
      name  = "replicas"
      value = 1
    }
  ]
}

resource "kubernetes_manifest" "karpenter_nodepool_amd64" {
  depends_on = [helm_release.karpenter]

  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "amd64"
    }

    spec = {
      disruption = {
        consolidationPolicy = "WhenEmpty"
        consolidateAfter    = "1m"
      }

      template = {
        metadata = {
          labels = {
            arch = "amd64"
            role = "workload"
          }
        }

        spec = {
          taints = [
            { key = "karpenter.sh/provisioned", value = "amd64", effect = "NoSchedule" }
          ]

          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "default"
          }

          requirements = [
            { key = "kubernetes.io/arch", operator = "In", values = ["amd64"] },
            { key = "karpenter.sh/capacity-type", operator = "In", values = ["spot", "on-demand"] },
            { key = "karpenter.k8s.aws/instance-family", operator = "In", values = ["m5", "c5"] }
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "karpenter_nodepool_arm64" {
  depends_on = [
    helm_release.karpenter,
    kubernetes_manifest.karpenter_ec2nodeclass
  ]

  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "arm64"
    }

    spec = {
      disruption = {
        consolidationPolicy = "WhenEmpty"
        consolidateAfter    = "1m"
      }

      template = {
        metadata = {
          labels = {
            arch = "arm64"
            role = "workload"
          }
        }

        spec = {
          taints = [
            { key = "karpenter.sh/provisioned", value = "arm64", effect = "NoSchedule" }
          ]

          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "default"
          }

          requirements = [
            { key = "kubernetes.io/arch", operator = "In", values = ["arm64"] },
            { key = "karpenter.sh/capacity-type", operator = "In", values = ["spot", "on-demand"] },
            { key = "karpenter.k8s.aws/instance-family", operator = "In", values = ["m6g", "c6g"] }
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
      name = "default"
    }
    spec = {
      amiFamily       = "Bottlerocket"
      instanceProfile = var.node_pod_execution_profile.name

      tags = {
        "karpenter.sh/discovery" = var.cluster.name
      }

      subnetSelectorTerms = [{
        tags = {
          "karpenter.sh/discovery" = var.cluster.name
        }
      }]

      amiSelectorTerms = [
        { id = var.arm_ami_id },
        { id = var.amd_ami_id }
      ]

      securityGroupSelectorTerms = [{
        tags = {
          "kubernetes.io/cluster/${var.cluster.name}" = "owned"
        }
      }]
    }
  }
}

