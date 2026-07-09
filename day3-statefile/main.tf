resource "aws_instance" "name" {
    ami = "ami-002192a70217ac181"
    instance_type = "t2.medium"
    tags = {
        Name = "vj"
    }
  
}