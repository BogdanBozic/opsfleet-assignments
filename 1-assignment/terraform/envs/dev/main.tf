locals {
  tags = {
    random = "a simple display of power"
  }
}

module "network" {
  source = "../../modules/network"

  project_name = var.project_name
  env          = var.env
  vpc_cidr     = var.vpc_cidr
  subnet_count = length(var.azs)
  azs          = var.azs

  tags = {
    common = local.tags
    vpc = {
      "kubernetes.io/cluster/${var.project_name}-${var.env}" = "shared"
    }
    private_subnets = {
      "kubernetes.io/cluster/${var.project_name}-${var.env}" = "owned"
      "kubernetes.io/role/internal-elb"                      = "1"
      "karpenter.sh/discovery"                               = "${var.project_name}-${var.env}"
    }
    public_subnets = {
      "kubernetes.io/cluster/${var.project_name}-${var.env}" = "owned"
      "kubernetes.io/role/elb"                               = "1"
    }
  }
}

module "eks" {
  source = "../../modules/eks"

  depends_on            = [module.network]
  eks_version           = var.eks_version
  kube_proxy_version    = var.kube_proxy_version
  coredns_addon_version = var.coredns_version
  nodes_ami_version     = var.nodes_ami_version
  cni_version           = var.cni_version
  vpc_id                = module.network.vpc.id
  vpc_cidr              = module.network.vpc.cidr
  env                   = var.env
  private_subnet_ids    = [for s in module.network.subnets.private : s.id]
  project_name          = var.project_name
  public_subnet_ids     = [for s in module.network.subnets.public : s.id]
  tags                  = local.tags
}

module "crds" {
  source = "../../modules/crds"

  depends_on             = [module.eks]
  karpenter_helm_version = var.karpenter_helm_version
}

module "karpenter" {
  source = "../../modules/karpenter"

  depends_on                 = [module.eks, module.network, module.crds]
  amd_ami_id                 = var.amd_ami_id
  arm_ami_id                 = var.arm_ami_id
  azs                        = var.azs
  cluster                    = module.eks.cluster
  karpenter_helm_version     = var.karpenter_helm_version
  node_pod_execution_profile = module.eks.node_pod_execution_profile
  node_pod_execution_role    = module.eks.node_pod_execution_role
  oidc_provider              = module.eks.oidc_provider
  tags                       = local.tags
}