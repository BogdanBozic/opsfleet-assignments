resource "aws_eks_node_group" "bootstrap" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-${var.env}-bootstrap"
  node_role_arn   = aws_iam_role.bootstrap.arn
  subnet_ids      = var.private_subnet_ids
  release_version = var.nodes_ami_version
  instance_types = ["m5.large"]
  ami_type = "BOTTLEROCKET_x86_64"

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

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.bootstrap-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.bootstrap-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.bootstrap-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.bootstrap-AmazonSSMManagedInstanceCore
  ]
}

resource "aws_iam_role" "bootstrap" {
  name = "${var.project_name}-${var.env}-bootstrap"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "bootstrap-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.bootstrap.name
}

resource "aws_iam_role_policy_attachment" "bootstrap-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.bootstrap.name
}

resource "aws_iam_role_policy_attachment" "bootstrap-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.bootstrap.name
}

resource "aws_iam_role_policy_attachment" "bootstrap-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bootstrap.name
}

resource "aws_iam_instance_profile" "node_pod_execution_profile" {
  name = "${var.project_name}-${var.env}-node-pod-execution"
  role = aws_iam_role.bootstrap.name
}
