# vpc
resource "aws_vpc" "vpc_name" {
    cidr_block = "192.0.0.0/16"
    tags = {
        Name = "Vj"
    }
  
}

# subnets
resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.vpc_name.id
    cidr_block = "192.0.0.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "Vj-subnet1"
    }
}

resource "aws_subnet" "subnet2" {
    vpc_id = aws_vpc.vpc_name.id
    cidr_block = "192.0.1.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "Vj-subnet2"
    }
}

resource "aws_subnet" "subnet3" {
    vpc_id = aws_vpc.vpc_name.id
    cidr_block = "192.0.2.0/24"
    availability_zone = "us-east-1c"
    tags = {
        Name = "Vj-subnet3"
    }
}

# internet gateway
resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.vpc_name.id
    tags = {
        Name = "Vj-ig"
    }
}
# route table for ig
resource "aws_route_table" "rt1" {
    vpc_id = aws_vpc.vpc_name.id
    tags = {
      Name = "Vj-ig-rt"
    }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig.id
    }    
}

# aws routetable subnet association
resource "aws_route_table_association" "route_table_association" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.rt1.id
}

# elastic ip creation
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "vj-nat-eip"
  }
}

# nat gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet2.id

  depends_on = [
    aws_internet_gateway.ig
  ]

  tags = {
    Name = "Vj-nat-gateway"
  }
}

# route table for nat
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_name.id

  tags = {
    Name = "Vj-private-rt"
  }

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

# subnet association with routetable for nat
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}
