resource "aws_instance" "name" {
    ami = var.ami_id
    instance_type = var.instance_type
    tags = {
        Name=var.tags
    }
  
}



# first run the terraform init command in the module