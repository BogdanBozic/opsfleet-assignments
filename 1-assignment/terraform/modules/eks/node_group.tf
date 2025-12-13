resource "aws_eks_node_group" "bootstrap" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-${var.env}-bootstrap"
  node_role_arn   = aws_iam_role.bootstrap.arn
  subnet_ids      = var.private_subnet_ids
  release_version = var.nodes_ami_version
  instance_types  = ["m5.large"]
  ami_type        = "BOTTLEROCKET_x86_64"

  launch_template {
    id      = aws_launch_template.bootstrap.id
    version = "$Latest"
  }

  labels = {
    role = "bootstrap"
  }

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.bootstrap-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.bootstrap-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.bootstrap-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.bootstrap-AmazonSSMManagedInstanceCore
  ]

  lifecycle {
    ignore_changes = [ launch_template[0].version ]
  }
}

resource "aws_launch_template" "bootstrap" {

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-${var.env}-node"
    }
  }
}
