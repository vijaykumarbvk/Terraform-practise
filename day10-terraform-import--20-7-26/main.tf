resource "aws_instance" "name" {
    ami = "ami-01edba92f9036f76e"
    instance_type = "t2.micro"
    tags = {
      Name = "sample"
    }
  
}

resource "aws_s3_bucket" "name" {
  bucket = "vijaykumar-prac-import"
}

resource "aws_s3_bucket_versioning" "name" {
    bucket = aws_s3_bucket.name.id
    versioning_configuration {
      status = "Enabled"
    }
  
}

# here bucket versioning is a another resource. terrform only sees whether the bucket is present or not 


#terraform import 
# terraform import aws_instance.name i-06bbd023a433c869f
