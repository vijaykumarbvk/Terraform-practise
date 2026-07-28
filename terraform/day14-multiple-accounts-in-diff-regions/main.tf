resource "aws_vpc" "vpc-e" {
  cidr_block = "10.0.0.0/16"
  provider = aws.vj-acc
  tags = {
    Name = "east-vpc"
  }
}

resource "aws_s3_bucket" "s3-e" {
  bucket = "vjcreatesinuseastregion1"
  provider = aws.vj-acc
}

resource "aws_vpc" "w" {
  cidr_block = "172.0.0.0/16"
  provider = aws.bvk-acc
  tags = {
    Name = "west-vpc"
  }
}

resource "aws_s3_bucket" "w" {
  bucket = "vjcreatesinuswestregion1"
  provider = aws.bvk-acc
}


# create 2 iam users. 
# 
# same steps works with the both iam users
# 
# aws configure --profile <name>
# give accesskey and secret accesskey
# give region and format
# 
# and then run these commands, terraform init, terraform plan and terraform apply -auto-approve respectively