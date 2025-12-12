resource "aws_vpc" "this" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.env}"
      "kubernetes.io/cluster/${var.project_name}-${var.env}" = "shared"
    }
  )
}

resource "aws_subnet" "public" {
  count = var.subnet_count
  vpc_id = aws_vpc.this.id

  cidr_block = cidrsubnet(
    var.vpc_cidr,
    8,
    count.index * 2
  )

  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name       = "${var.project_name}-${var.env}-public-${count.index}"
      Accessibility  = "public"
      "kubernetes.io/cluster/${var.project_name}-${var.env}" = "owned"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

resource "aws_subnet" "private" {
  count = var.subnet_count
  vpc_id = aws_vpc.this.id

  cidr_block = cidrsubnet(
    var.vpc_cidr,
    8,
    count.index * 2 + 1
  )

  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name       = "${var.project_name}-${var.env}-private-${count.index}"
      Accessibility  = "private"
      "kubernetes.io/cluster/${var.project_name}-${var.env}" = "owned"
      "kubernetes.io/role/internal-elb" = "1"
      "karpenter.sh/discovery" = "${var.project_name}-${var.env}"
    }
  )
}
