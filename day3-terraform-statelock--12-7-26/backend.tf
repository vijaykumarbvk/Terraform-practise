terraform {
  backend "s3" {
    bucket = "vij12oasljafidobvj"
    key = "terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
    dynamodb_table = "vj-logs"
  }
}