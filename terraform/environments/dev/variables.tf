
variable "enable_eks" {
  description = "Whether to deploy the Amazon EKS cluster and supporting resources"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT Gateway for private subnet outbound access"
  type        = bool
  default     = false
}
