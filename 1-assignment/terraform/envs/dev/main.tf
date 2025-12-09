locals {
  tags = {
    project = var.project_name
    environment = var.env
  }
}

module "network" {
  source = "../../modules/network"

  project_name = var.project_name
  env = var.env
  vpc_cidr = var.vpc_cidr
  subnet_count = var.subnet_count
  azs = var.azs
  tags = local.tags
}

module "eks" {
  source = "../../modules/eks"
  depends_on = [module.network]
  eks_version = var.eks_version
  kube_proxy_version = var.kube_proxy_version
  cni_version = var.cni_version
  vpc_id = module.network.vpc.id
  vpc_cidr = module.network.vpc.cidr
  env = var.env
  private_subnet_ids = [for s in module.network.subnets.private : s.id]
  project_name = var.project_name
  public_subnet_ids = [for s in module.network.subnets.public : s.id]
  tags = local.tags
}
