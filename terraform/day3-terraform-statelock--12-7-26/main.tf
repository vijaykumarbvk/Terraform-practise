resource "aws_instance" "name" {
    ami = var.ami_id
    instance_type = var.instance_type
    tags = {
        Name= var.tags
    }
  
}

resource "aws_s3_bucket" "bucket_name" {
    bucket = var.bucket_name
    tags = {
        Environment = var.Environment
        ManagedBy = "Terraform"
    }
}

resource "aws_dynamodb_table" "dynamodb_table" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key

  # The attribute block must match the hash_key name and define its data type
  # "S" stands for String
  attribute {
    name = var.hash_key
    type = "S" 
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}