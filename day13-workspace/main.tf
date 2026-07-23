resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"
  tags={
    Name = "work"
  }
}

resource "aws_instance" "name" {
    ami = "ami-002192a70217ac181"
    instance_type = "t2.micro" 
}


# in terraform work space creates just like different env. each env has their own statefile, so it is not good approach now a days no one using it