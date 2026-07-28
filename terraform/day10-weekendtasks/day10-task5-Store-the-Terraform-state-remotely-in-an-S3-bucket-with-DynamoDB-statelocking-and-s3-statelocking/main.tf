resource "aws_s3_bucket" "s3_bucket" {
    bucket = "vj-prac-terraform-day10"
}

resource "aws_instance" "name" {
    ami = "ami-01edba92f9036f76e"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    tags = {
        Name = "statelock"
    }
}

resource "aws_s3_bucket" "s3_bucket-3" {
    bucket = "vj-prac-terraform-day10-1"
}
