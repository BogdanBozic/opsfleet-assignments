data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

resource "aws_eks_cluster" "this" {
  name                          = "${var.project_name}-${var.env}"
  role_arn                      = aws_iam_role.cluster.arn
  version                       = var.eks_version
  enabled_cluster_log_types     = ["api", "audit"]
  bootstrap_self_managed_addons = false

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["${chomp(data.http.myip.response_body)}/32"]
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.private.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}
