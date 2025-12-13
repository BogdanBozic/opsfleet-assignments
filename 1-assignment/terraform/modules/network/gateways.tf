resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    try(var.tags.common, {}),
    try(var.tags.igw, {}),
    {
      Name = "igw-${aws_vpc.this.id}"
    }
  )
}

resource "aws_eip" "this" {
  count = var.subnet_count

  tags = merge(
    try(var.tags.common, {}),
    try(var.tags.eip, {}),
    {
      Name = "${var.project_name}-${var.env}-nat-${count.index}"
    }
  )
}

resource "aws_nat_gateway" "this" {
  count         = var.subnet_count
  depends_on    = [aws_internet_gateway.this]
  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    try(var.tags.common, {}),
    try(var.tags.nat, {}),
    {
      Name = "${var.project_name}-${var.env}-nat-${count.index}"
    }
  )
}
