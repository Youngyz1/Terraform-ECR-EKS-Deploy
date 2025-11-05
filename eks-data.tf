# eks-data.tf

# Fetch authentication token for the Kubernetes provider
data "aws_eks_cluster_auth" "main_eks" {
  name = aws_eks_cluster.main_eks.name
}
