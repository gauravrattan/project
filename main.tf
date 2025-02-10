
module "vpc" {
  source             = "./module/vpc"  
  vpc_cidr           = var.vpc_cidr           # Pass vpc_cidr variable
  organization_prefix = var.organization_prefix # Pass organization_prefix variable
  enable_dns_support  = var.enable_dns_support  # Pass other variables as needed
  enable_dns_hostnames = var.enable_dns_hostnames
  public_subnets      = var.public_subnets
  app_subnets         = var.app_subnets
  db_subnets          = var.db_subnets
  create_nat_gateway  = var.create_nat_gateway
}


resource "aws_security_group" "postgres_sg" {
name = "postgres_sg"
description = "Security Group for Postgres EC2 instances"
vpc_id = module.vpc.vpc_id

ingress {
from_port = 5432
to_port = 5432
protocol = "tcp"
cidr_blocks = [module.vpc.cidr_block]
}

egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}


resource "aws_instance" "postgres_master" {
ami = "ami-0672fd5b9210aa093"
instance_type = var.instance_type
subnet_id = module.vpc.app_private_subnets[0]
security_groups = [aws_security_group.postgres_sg.id]
iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
key_name = "postgres-key"
associate_public_ip_address = false
tags = {
Name = "postgres-master"
}
}

resource "aws_instance" "postgres_worker" {
ami = "ami-0672fd5b9210aa093"
instance_type = var.instance_type
subnet_id = module.vpc.app_private_subnets[1]
security_groups = [aws_security_group.postgres_sg.id]
iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
associate_public_ip_address = false
key_name = "postgres-key"
tags = merge({
Name = "postgres-worker-${count.index + 1}"
}, var.env_tags)

count = var.postgres_worker_replicas
}

