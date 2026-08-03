# Point to the exact same module
terraform {
  source = "../../modules/ec2-app"
}

# These replace your prod.tfvars variables
inputs = {
  instance_type = "t3.medium"
  environment   = "prod"
}