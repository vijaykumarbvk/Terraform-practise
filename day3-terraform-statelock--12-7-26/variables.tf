variable "ami_id" {
    description = "ami_id for the instance"
    type = string
    default = ""
  
}

variable "instance_type" {
    description = "instance_type for the instance"
    type = string
    default = ""
  
}

variable "tags" {
    description = "tag name for the instance"
    type = string
    default = ""
  
}

variable "bucket_name" {
    description = "s3 bucket for storing the statelock"
    type = string
    default = ""
  
}

variable "Environment" {
  description = "the deployment environment (e.g.. dev, staging, prod)"
  type = string
  default = "dev"
}

variable "table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "The partition key for the table"
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}