resource "aws_eks_node_group" "bootstrap" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-${var.env}-bootstrap"
  node_role_arn   = aws_iam_role.bootstrap.arn
  subnet_ids      = var.private_subnet_ids
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  instance_types = ["m5.large"]

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

  launch_template {
    id      = aws_launch_template.eks_launch_template.id
    version = "$Latest"
  }


  lifecycle {
    ignore_changes = [ launch_template[0].version ]
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

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.this.version}/amazon-linux-2023/x86_64/standard/recommended/release_version"
}

resource "aws_launch_template" "eks_launch_template" {
  name = "${var.project_name}-${var.env}"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted   = false
      volume_size = 20
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.private.id]
  }

  user_data = base64encode(templatefile("${path.module}/scripts/userdata.sh.tmpl", {
    cluster_name          = aws_eks_cluster.this.name
    api_server_endpoint   = aws_eks_cluster.this.endpoint
    certificate_authority = aws_eks_cluster.this.certificate_authority[0].data
    service_ipv4_cidr     = aws_eks_cluster.this.kubernetes_network_config[0].service_ipv4_cidr
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      "kubernetes.io/cluster/${aws_eks_cluster.this.name}" = "owned"
      "Name" = "${var.project_name}-${var.env}-node"
    }
  }
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
