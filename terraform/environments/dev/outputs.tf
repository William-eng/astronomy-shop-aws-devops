output "aws_region" {
  description = "AWS Region for the Astronomy Shop infrastructure"
  value       = "us-east-1"
}

output "vpc_id" {
  description = "Astronomy Shop VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "Astronomy Shop VPC CIDR"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}
