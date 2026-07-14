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
