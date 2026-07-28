variable "ami_id" {
    description = "The AMI ID for the EC2 instance"
    type = string
    default = ""
}
variable "instance_type" {
    description = "The instance type for the EC2 instance"
    type = string
    default = ""
}
variable "tags" {
    description = "The tags for the EC2 instance"
    type = string
    default = ""
}

#terraform apply -var="ami_id=ami-002192a70217ac181" -var="instance_type=t2.micro" -var="tags=test-instance"