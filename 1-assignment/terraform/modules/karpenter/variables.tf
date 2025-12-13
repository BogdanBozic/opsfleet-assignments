variable "oidc_provider" {
  description = "OIDC provider configuration for the EKS cluster, used by Karpenter and other components for IAM roles for service accounts (IRSA)."
  type = object({
    arn = string
    url = string
  })
}

variable "cluster" {
  description = "EKS cluster metadata including name, endpoint, and Kubernetes version."
}

variable "tags" {
  description = "Common tags applied to all AWS resources created by this module."
  type        = map(string)
}

variable "karpenter_helm_version" {
  description = "Version of the Karpenter Helm chart to deploy into the EKS cluster."
  type        = string
}

variable "node_pod_execution_role" {
  description = "IAM role assumed by Karpenter-managed worker nodes for accessing AWS services."
  type = object({
    arn  = string
    name = string
  })
}

variable "node_pod_execution_profile" {
  description = "IAM instance profile used by Karpenter-managed EC2 nodes."
  type = object({
    arn  = string
    name = string
  })
}

variable "azs" {
  description = "List of availability zones in which Karpenter is allowed to provision EC2 instances."
  type        = list(string)
}

variable "amd_ami_id" {
  description = "Pinned Bottlerocket AMI ID for amd64 (x86_64) worker nodes."
  type        = string
}

variable "arm_ami_id" {
  description = "Pinned Bottlerocket AMI ID for arm64 (Graviton) worker nodes."
  type        = string
}

