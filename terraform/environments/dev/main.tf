module "vpc" {
  source = "../../modules/vpc"

  enable_nat_gateway = var.enable_nat_gateway

  project_name = "astronomy-shop"
  environment  = "dev"

  vpc_cidr = "10.20.0.0/16"

  availability_zones = [
    "us-east-1a",
    "us-east-1b"
  ]

  public_subnet_cidrs = [
    "10.20.1.0/24",
    "10.20.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.20.11.0/24",
    "10.20.12.0/24"
  ]
}

# ------------------------------------------------------------
# Optional Amazon EKS Cluster
# ------------------------------------------------------------

module "eks" {
  count  = var.enable_eks ? 1 : 0
  source = "../../modules/eks"

  project_name = "astronomy-shop"
  environment  = "dev"

  cluster_version = "1.34"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  node_instance_types = ["t3.medium"]
  node_desired_size   = 1
  node_min_size       = 1
  node_max_size       = 2

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = []

  cluster_admin_principal_arn = "arn:aws:iam::975050251876:user/me-only1"
}

