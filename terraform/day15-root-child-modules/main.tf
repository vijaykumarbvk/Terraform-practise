provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  cidr = var.cidr
}

module "ec2" {
  source = "./modules/ec2"
        
                      #root variable
  ami               = var.ami
  #child variable
  instance_type     =       var.instance_type
  subnet_id = "subnet-0e0c3d9c641581f76"
}

module "security_group" {
  source = "./modules/security_group"

  vpc_id         = module.vpc.vpc_id      #if u havent run terraform apply use this module.vpc.vpc_id.id  
  sg_name        = var.sg_name
  sg_description = var.sg_description
  ingress_rules  = var.ingress_rules
  tags           = var.tags
}

output "web_sg_id" {
  description = "The ID of the security group created by the module"
  value       = module.security_group.security_group_id
}