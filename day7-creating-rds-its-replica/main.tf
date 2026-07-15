resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "main-subnet-1"
  }
}

resource "aws_subnet" "subnet2" {
    vpc_id      = aws_vpc.vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "main-subnet-2"
    }
}

resource "aws_subnet" "subnet3" {
    vpc_id     = aws_vpc.vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1c"
    tags = {
        Name = "main-subnet-3"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    tags ={
        Name = "main-igw"
    }
}

resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "main-route-table"
    }

       route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "rta1" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.route_table.id

}

resource "aws_route_table_association" "rta2" {
    subnet_id = aws_subnet.subnet2.id
    route_table_id = aws_route_table.route_table.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "main-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
#   subnet_id     = aws_subnet.subnet3.id
  vpc_id = aws_vpc.vpc.id
  availability_mode = "regional"
  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name = "main-nat-gateway"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "main-private-route-table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "main-sg" {
  name        = "main-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
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

resource "aws_db_subnet_group" "db_subnet_group" {
    name = "main-db-subnet-group"
    subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
    tags = {
        Name = "main-db-subnet-group"
    }
}

resource "aws_db_instance" "db_instance" {
    identifier = "main-db-instance"
    allocated_storage =20
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    username = "admin"
    password = "admin123" #self managed password
    #managed_master_user_password = true  #enable password management by AWS Secrets Manager
    db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
    vpc_security_group_ids = [aws_security_group.main-sg.id]
    publicly_accessible = false
    skip_final_snapshot = true
    maintenance_window = "Mon:00:00-Mon:03:00"
    backup_retention_period = 7     #max retention period is 35 days

}

resource "aws_db_instance" "replica_db" {
    identifier = "replica-db-instance"
    allocated_storage = 20
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    storage_type = "gp2"
    publicly_accessible = false
    vpc_security_group_ids = [aws_security_group.main-sg.id]
    db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
    replicate_source_db = aws_db_instance.db_instance.arn

}

resource "aws_elasticache_serverless_cache" "redis_cache" {
    engine = "redis"
    name = "main-redis-cache"
}