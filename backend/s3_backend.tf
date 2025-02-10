resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket
  acl    = "private"
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.dynamodb_table
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock"
  }
}



