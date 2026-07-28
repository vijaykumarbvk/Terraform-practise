variable "ami_id" {
    description = "the ami id for the ec2 instance"
    type = string
    default = ""
  
}

variable "instance_type" {
    description = "the instance type for the ec2 instance"
    type = string
    default = ""
  
}

variable "tags" {
    description = "the tags for the ec2 instance"
    type = string
    default = ""
  
}