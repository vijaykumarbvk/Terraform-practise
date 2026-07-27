resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vj"
  }
}

resource "aws_s3_bucket" "name" {
  bucket = "hdtydtdyjjykioiohoi"
}