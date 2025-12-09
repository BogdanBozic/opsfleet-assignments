data "tls_certificate" "oidc_web_identity" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider_sts" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_web_identity.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  tags            = var.tags
}

resource "aws_iam_role" "eks_vpc_cni_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_vpc_cni_role.json
  name               = "${aws_eks_cluster.this.name}-vpc-cni-role"
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_vpc_cni_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_vpc_cni_role.name
}

data "aws_iam_policy_document" "eks_vpc_cni_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider_sts.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider_sts.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_provider_sts.arn]
      type        = "Federated"
    }
  }
}

resource "aws_eks_addon" "eks_cluster_vpc_cni" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "vpc-cni"
  addon_version               = var.cni_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = aws_iam_role.eks_vpc_cni_role.arn
  tags                        = var.tags

  configuration_values = jsonencode({
    env = {
      ENABLE_POD_ENI = "true"
    },
    init = {
      env = {
        DISABLE_TCP_EARLY_DEMUX = "true"
      }
    }
  })
}

resource "aws_eks_addon" "eks-cluster-kube-proxy" {
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "kube-proxy"
  addon_version               = var.kube_proxy_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags                        = var.tags
}