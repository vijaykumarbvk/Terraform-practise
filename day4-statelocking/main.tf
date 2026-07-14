resource "aws_s3_bucket" "s3_bucket" {
    bucket = "vj-prac-terraform-day4-again"
}

resource "aws_instance" "name" {
    ami = "ami-002192a70217ac181"
    instance_type = "t2.micro"
    tags = {
        Name = "dev-2"
    }
  
}

resource "aws_instance" "name3" {
    ami = "ami-01edba92f9036f76e"
    instance_type = "t2.medium"
    tags = {
        Name = "dev-4"
    }
  
}
