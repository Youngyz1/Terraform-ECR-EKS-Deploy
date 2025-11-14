############################################
# IAM ROLES AND POLICIES FOR EKS
############################################

# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach EKS Cluster Policies
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

############################################
# EKS CLUSTER
############################################

resource "aws_eks_cluster" "main_eks" {
  name     = var.cluster_name
  version  = "1.31"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.public["public-1"].id,
      aws_subnet.public["public-2"].id,
      aws_subnet.private["private-1"].id,
      aws_subnet.private["private-2"].id
    ]

    security_group_ids     = [aws_security_group.sg.id]
    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy
  ]

  # Add generous timeouts for EKS lifecycle
  # EKS cluster deletion is asynchronous and can take 10-15+ minutes
  timeouts {
    create = "30m"
    delete = "30m"
    update = "60m"
  }

}

############################################
# EKS NODE GROUP IAM ROLE
############################################

resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach required policies for worker nodes
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_readonly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

############################################
# EKS MANAGED NODE GROUP
############################################

resource "aws_eks_node_group" "main_node_group" {
  cluster_name    = aws_eks_cluster.main_eks.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = [
    aws_subnet.private["private-1"].id,
    aws_subnet.private["private-2"].id
  ]

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_eks_cluster.main_eks,
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_readonly
  ]

  # Add timeouts for node group lifecycle operations
  timeouts {
    create = "30m"
    delete = "30m"
    update = "30m"
  }
}
