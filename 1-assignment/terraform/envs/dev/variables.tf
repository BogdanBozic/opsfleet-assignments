variable "env" {
  description = "The environment name, e.g., dev, staging, prod. Used in resource naming and tagging."
  type        = string
}

variable "project_name" {
  description = "The name of the project or application. Used in resource naming for clarity."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC, e.g., 10.0.0.0/16."
  type        = string
}

variable "azs" {
  description = "List of Availability Zones to use for subnet placement. Subnets will be evenly distributed across these AZs."
  type        = list(string)
}

variable "eks_version" {
  description = "The Kubernetes version to deploy in the EKS cluster, e.g., 1.28."
  type        = string
}

variable "cni_version" {
  description = "The version of the AWS VPC CNI plugin to deploy in the cluster for pod networking."
  type        = string
}

variable "kube_proxy_version" {
  description = "The version of kube-proxy to deploy in the cluster for service networking."
  type        = string
}

variable "coredns_version" {
  description = "The version of CoreDNS to deploy in the cluster for DNS resolution."
  type        = string
}

variable "nodes_ami_version" {
  description = "The EKS-optimized AMI version for the bootstrap node group."
  type        = string
}

variable "amd_ami_id" {
  description = "The AMI ID to use for x86_64 (AMD/Intel) Karpenter nodes."
  type        = string
}

variable "arm_ami_id" {
  description = "The AMI ID to use for ARM64 (Graviton) Karpenter nodes."
  type        = string
}

variable "karpenter_helm_version" {
  description = "The Helm chart version of Karpenter to deploy in the cluster."
  type        = string
}
