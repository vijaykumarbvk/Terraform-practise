terraform {
  backend "s3" {
    bucket = "vj-prac-terraform-day4"
    key = "terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}


# use_lockfile = true ## supports terraform latest version >= 1.10
# dynamodb_table = "terraform-state-locking"  # if terraform version < 1.10 use below code
# Note: the S3 bucket used for backend state must already exist before terraform init.
