# module/vpc/outputs.tf

# Output the VPC ID
output "vpc_id" {
  value       = aws_vpc.main_vpc.id
  description = "The ID of the VPC"
}

# Output the VPC CIDR block
output "cidr_block" {
  value       = aws_vpc.main_vpc.cidr_block
  description = "The CIDR block of the VPC"
}

# Output for the app private subnets
output "app_private_subnets" {
  value       = aws_subnet.app_private_subnets[*].id
  description = "The list of private subnets for the app tier"
}
