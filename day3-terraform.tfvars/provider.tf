provider "aws" {
  
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.53.0"
      #version = ">6.53.0"
      #version = >4.0.0, <5.0.0 #example of provider version constraint
    }
  }
}