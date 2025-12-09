resource "aws_security_group" "private" {
  name        = "${var.project_name}-${var.env}-private"
  description = "SG for private resources of ${var.project_name}-${var.env} cluster"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "private_allow_all_ingress" {
  description       = "Allow all internal traffic from the same VPC"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.private.id
  to_port           = 0
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "private_allow_all_outbound" {
  description       = "Allow all outbound traffic"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.private.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
