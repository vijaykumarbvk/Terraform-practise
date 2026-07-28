resource "aws_instance" "name" {
    ami = "ami-002192a70217ac181"
    instance_type = "t2.micro"
    for_each = toset(var.tags)
    tags = {
        Name = each.key
    }
  
}



# with for_each we can delete the specific resource only without disturbing the other resources. so it is recommended than count