variable "public_subnet_ids" {
  description = "List of public subnet IDs in which public-facing resources (such as load balancers) may be created."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs used by the EKS cluster and Karpenter-managed worker nodes."
  type        = list(string)
}

variable "eks_version" {
  description = "Kubernetes version to use for the EKS control plane."
  type        = string
}

variable "project_name" {
  description = "Name of the project or application, used for naming and tagging AWS resources."
  type        = string
}

variable "env" {
  description = "Deployment environment identifier (e.g. dev, staging, prod)."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all AWS resources created by this module."
  type        = map(string)
}

variable "vpc_id" {
  description = "ID of the VPC in which the EKS cluster and associated resources are deployed."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC, used for networking configuration and security rules."
  type        = string
}

variable "cni_version" {
  description = "Version of the Amazon VPC CNI plugin to install as an EKS add-on."
  type        = string
}

variable "kube_proxy_version" {
  description = "Version of the kube-proxy add-on to install in the EKS cluster."
  type        = string
}

variable "coredns_addon_version" {
  description = "Version of the CoreDNS add-on to install in the EKS cluster."
  type        = string
}

variable "nodes_ami_version" {
  description = "Version identifier for the node AMI used by worker nodes (for example, a Bottlerocket or EKS-optimized AMI version)."
  type        = string
}
