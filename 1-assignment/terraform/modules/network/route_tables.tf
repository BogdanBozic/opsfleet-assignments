##############
### PUBLIC ###
##############

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    try(var.tags.common, {}),
    try(var.tags.route_tables, {}),
    {
      Name = "${var.project_name}-${var.env}-public"
    }
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

###############
### PRIVATE ###
###############

resource "aws_route_table" "private" {
  count  = var.subnet_count
  vpc_id = aws_vpc.this.id

  tags = merge(
    try(var.tags.common, {}),
    try(var.tags.route_tables, {}),
    {
      Name = "${var.project_name}-${var.env}-private-${count.index}"
    }
  )
}

resource "aws_route" "private_nat" {
  count                  = var.subnet_count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
