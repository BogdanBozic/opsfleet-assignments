resource "aws_vpc" "this" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.env}"
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
      Visibility = "public"
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
      Visibility = "private"
    }
  )
}
