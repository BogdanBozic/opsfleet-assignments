variable "env" {
  description = "The environment name, e.g., dev, staging, prod. Used in resource naming and tagging."
  type        = string
}

variable "project_name" {
  description = "The name of the project or application. Used in resource naming for clarity."
  type        = string
}

variable "subnet_count" {
  description = "Number of public and private subnets to create in the VPC. Each type will have this many subnets."
  type        = number
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
  type = string
}

variable "cni_version" {}
variable "kube_proxy_version" {}
variable "coredns_version" {}