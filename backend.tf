terraform {
  backend "s3" {
    bucket         = "terraform-bucket-ansible-ssm-gaurav"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "ansible-ssm-table"
    acl            = "private"
  }
}