# resource "aws_eks_node_group" "default" {
#   cluster_name    = aws_eks_cluster.this.name
#   node_group_name = "${var.project_name}-${var.env}-default"
#   node_role_arn   = aws_iam_role.eks_node_worker_group.arn
#   subnet_ids      = var.private_subnet_ids
#
#   ami_type = "AL2023_x86_64_STANDARD"
#
#   labels = {
#     role = "default"
#   }
#
#   scaling_config {
#     desired_size = 1
#     max_size     = 2
#     min_size     = 1
#   }
#
#   update_config {
#     max_unavailable = 1
#   }
#
#   tags = var.tags
# }

# resource "aws_eks_node_group" "default" {
#   cluster_name    = aws_eks_cluster.this.name
#   node_group_name = "${var.project_name}-${var.env}-default"
#   node_role_arn   = aws_iam_role.eks_node_worker_group.arn
#   subnet_ids      = var.private_subnet_ids
#   ami_type = "AL2023_x86_64_STANDARD"
#
#   labels = {
#     role = "default"
#   }
#
#   scaling_config {
#     desired_size = 1
#     max_size     = 2
#     min_size     = 1
#   }
#
#   update_config {
#     max_unavailable = 1
#   }
#
#   depends_on = [
#     aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
#     aws_iam_role_policy_attachment.node_group_ssm
#   ]
#
#   tags = var.tags
# }

# resource "aws_iam_role" "eks_node_worker_group" {
#   name = "${var.project_name}-${var.env}-eks-node-worker-group"
#
#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
#
#   tags = var.tags
# }
#
# resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.eks_node_worker_group.name
# }
#
# resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks_node_worker_group.name
# }
#
# resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.eks_node_worker_group.name
# }
#
# resource "aws_iam_role_policy_attachment" "node_group_ssm" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   role       = aws_iam_role.eks_node_worker_group.name
# }
