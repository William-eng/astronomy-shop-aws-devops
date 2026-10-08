variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC where the EKS cluster will run"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for public-facing load balancers"
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API endpoint is publicly accessible"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "Approved IPv4 CIDR ranges allowed to access the public EKS API endpoint"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.cluster_endpoint_public_access_cidrs :
      can(cidrhost(cidr, 0))
    ])
    error_message = "Each entry must be a valid IPv4 or IPv6 CIDR."
  }
}

variable "cluster_admin_principal_arn" {
  description = "IAM role or user ARN authorized to administer the EKS cluster"
  type        = string
}
