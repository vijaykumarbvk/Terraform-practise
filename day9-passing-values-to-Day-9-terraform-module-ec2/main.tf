module "dev" {
    source ="../day9-terraform-module-ec2"
    # source = "github.com/shivamani3286-cloud/terraform/tree/main/day-9-module"    using github
    ami_id = "ami-01edba92f9036f76e"
    instance_type = "t3.micro"
    tags = "dev-instance"
  
}