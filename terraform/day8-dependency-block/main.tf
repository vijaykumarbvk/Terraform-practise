resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
  tags ={
    Name = "VJ"
  }
  depends_on = [aws_s3_bucket.bucketprac]
}

resource "aws_s3_bucket" "bucketprac" {
    bucket = "bucketprac-vj12340987"

}

# dependency block is used to create a dependency between resources. In this case, 
# The VPC creation depends on the S3 bucket creation. 
# This ensures that the S3 bucket is created before the VPC is created.
# Here we are creating a VPC and S3 bucket, and the VPC creation depends on the S3 bucket creation. 