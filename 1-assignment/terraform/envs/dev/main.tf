module "network" {
  source = "../../modules/network"

  project_name = var.project_name
  env = var.env
  vpc_cidr = var.vpc_cidr
  subnet_count = var.subnet_count
  azs = var.azs
  tags = {
    project = var.project_name
    environment = var.env
  }
}