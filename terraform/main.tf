resource "aws_iam_role" "eks_cluster" {
  name = var.eks_cluster

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "eks_cluster_policy" {
  name       = "eks-cluster-policy"
  roles      = [aws_iam_role.eks_cluster.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_policy_attachment" "eks_cluster_policy_cni_policy" {
  name       = "eks-cluster-policy_cni_policy"
  roles      = [aws_iam_role.eks_cluster.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = var.aws_subnets
    values = [data.aws_vpc.default.id]
  }
}


resource "aws_eks_cluster" "eks" {
  name     = var.aws_eks_cluster
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = data.aws_subnets.public.ids
  }
}

resource "aws_iam_role" "matrix" {
  name = var.aws_iam_role

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

resource "aws_iam_role_policy_attachment" "matrix-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.matrix.name
}

resource "aws_iam_role_policy_attachment" "matrix-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.matrix.name
}

resource "aws_iam_role_policy_attachment" "matrix-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.matrix.name
}


resource "aws_eks_node_group" "matrix" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.matrix.arn
  subnet_ids      = data.aws_subnets.public.ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types

  depends_on = [
    aws_iam_role_policy_attachment.matrix-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.matrix-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.matrix-AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.eks
  ]
  tags = {
    Name        = "MATRIX"
    Environment = "DEV"
  }
}