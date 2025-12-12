output "oidc_provider" {
  value = aws_iam_openid_connect_provider.oidc_provider_sts
}

output "cluster" {
  value = aws_eks_cluster.this
}

output "node_pod_execution_role" {
  value = aws_iam_role.bootstrap
}

output "node_pod_execution_profile" {
  value = aws_iam_instance_profile.node_pod_execution_profile
}

output "ami_release" {
  value = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.version)
}