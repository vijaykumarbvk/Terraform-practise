output "publicip" {
    description = "Public IP of the instance"
    value = aws_instance.public_instance.public_ip
  
}

output "privateip" {
    description = "Private IP of the instance"
    value = aws_instance.public_instance.private_ip
}

output "instance_id" {
    description = "ID of the instance"
    value = aws_instance.public_instance.id
}

output "az" {
    description = "Availability Zone of the instance"
    value = aws_instance.public_instance.availability_zone
}

output "vpc_id" {
    description = "VPC ID of the instance"
    value = aws_instance.public_instance.vpc_security_group_ids
}