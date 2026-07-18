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

resource "aws_instance" "ec2" {
  ami = "ami-01edba92f9036f76e"
  instance_type = "t2.medium"
  subnet_id = aws_subnet.subnet1.id
  associate_public_ip_address = true
    tags = {
        Name = "server"
    }
    security_groups = [aws_security_group.sg.id]
  
}

resource "aws_security_group" "sg" {
    name        = "server_sg"
  description = "Security group for prod VPC"
  vpc_id      = aws_vpc.vpc_name.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# creation of security group for ALB
resource "aws_security_group" "alb_security_group" {
  name        = "custom-alb-security-group"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = aws_vpc.vpc_name.id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_lb" "lb" {
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_security_group.id]
  subnets = [aws_subnet.subnet1.id, aws_subnet.subnet3.id, aws_subnet.subnet2.id]

  tags = {
    Name = "alb"
  }
}

resource "aws_lb_target_group" "tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_name.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = {
    Name = "custom-target-group"
  }
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
 resource "aws_lb_target_group_attachment" "target_group_attachment" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.ec2.id
  port             = 80
 }