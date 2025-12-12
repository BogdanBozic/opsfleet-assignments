terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 3.1.1"
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster.endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster.certificate_authority[0].data)
    exec = {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster.name]
    env = {
       AWS_DEFAULT_OUTPUT = "json"
    }
  }
  }
}

provider "kubernetes" {
   host                   = module.eks.cluster.endpoint
   cluster_ca_certificate = base64decode(module.eks.cluster.certificate_authority[0].data)
   exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster.name]
    env = {
       AWS_DEFAULT_OUTPUT = "json"
    }
  }
}
