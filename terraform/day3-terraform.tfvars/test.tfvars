ami_id = "ami-002192a70217ac181"
instance_type = "t2.micro"
tags = "test-tfvars-name"

# my tf vars name is test.tfvars
# tfvars file name should be terraform.tfvars for terraform to automatically pick it up. 
# If you want to use a different name, you can specify it with the -var-file option when running terraform commands.
# Example: terraform apply -var-file="test.tfvars"