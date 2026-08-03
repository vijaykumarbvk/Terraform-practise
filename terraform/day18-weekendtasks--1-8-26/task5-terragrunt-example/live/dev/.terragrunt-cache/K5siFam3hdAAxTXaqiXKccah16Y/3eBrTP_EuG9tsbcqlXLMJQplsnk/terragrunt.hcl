# Point to the generic module
terraform {
  source = "../../modules/ec2-app"
}

# These replace your dev.tfvars variables
inputs = {
  instance_type = "t2.micro"
  environment   = "dev"
}