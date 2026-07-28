resource "aws_vpc" "prod" {
    cidr_block = "172.0.0.0/16"
    tags = {
        Name = "prod"
    }
  
}

resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.prod.id
    cidr_block = "172.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"
    tags = {
        Name = "prod-subnet-public"
    }
  
}

resource "aws_subnet" "subnet2" {
    vpc_id = aws_vpc.prod.id
    cidr_block = "172.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "prod-subnet-private"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.prod.id
    tags = {
        Name = "prod-igw"
    }
  
}

resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.prod.id
    tags = {
        Name = "prod-route-table"
    }

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
  
}

resource "aws_route_table_association" "route_table_association" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.route_table.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "prod-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet1.id

  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name = "prod-nat-gateway"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.prod.id

  tags = {
    Name = "prod-private-route-table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "prod_sg" {
  name        = "prod-sg"
  description = "Security group for prod VPC"
  vpc_id      = aws_vpc.prod.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_instance" "public_instance" {
#   ami           = "ami-0fd6b4bfb40773c2d"
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.subnet1.id
#   security_groups = [aws_security_group.prod_sg.id]

#   tags = {
#     Name = "prod-public-instance"
#   }
  
# }

resource "aws_instance" "private_instance" {
  ami           = "ami-01edba92f9036f76e"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet2.id
  security_groups = [aws_security_group.prod_sg.id]

  tags = {
    Name = "prod-private-instance"
  }
}
 
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "prod-db-subnet-group"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    Name = "prod-db-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.prod.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.prod_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  db_name                = "prod_db"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "password$123"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
   publicly_accessible = false

  tags = {
    Name = "prod-mysql-db"
  }
}