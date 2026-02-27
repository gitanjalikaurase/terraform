resource "aws_iam_role" "cluster_role" {
  name = "cluster_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    env = var.env
  }
}

resource "aws_iam_policy_attachment" "cluster-policy-attachment" {
  name       = "cluster-policy-attachment"
  roles      = [aws_iam_role.cluster_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "default_subnets" {
  filter {
    name = "vpc-id"
    values = [data.AWS_VPC.DEFAULT_VPC.ID]
  }
}

resource "aws_eks_cluster" "my_cluster" {
  name = "my_cluster"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster_role.arn
  version  = "1.34"

  vpc_config {
    subnet_ids = data.aws_subnet.default_subnets.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
  
timeouts {
    create = "20m"
  } 
}


resource "aws_iam_role" "node_role" {
  name = "node_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    env = var.env
  }
}

resource "aws_iam_policy_attachment" "cluster-policy-attachment" {
  name       = "node_policy_attachment"
  roles      = [aws_iam_role.cluster_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_policy_attachment" "cluster-policy-attachment" {
  name       = "cluster_node_policy_attachment"
  roles      = [aws_iam_role.cluster_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_policy_attachment" "cluster-policy-attachment" {
  name       = "node_policy_attachment1"
  roles      = [aws_iam_role.cluster_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "example"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = data.aws_subnet.drfault_subnets.ids
  instance_type = [t3 micro]

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_policy_attachment.node_policy_attachment,
    aws_iam_policy_attachment.cluster_node_policy_attachment,
    aws_iam_policy_attachment.node_policy_attachment1,
  ]
  timeout {
    create = "20m"
  }
}


