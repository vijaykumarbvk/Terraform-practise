provider "aws" {
    profile = "vijay"
    alias = "vj-acc"
    region = "us-east-1"  
}

provider "aws" {
  profile = "kumar"
  alias = "bvk-acc"
  region = "us-west-2"
}