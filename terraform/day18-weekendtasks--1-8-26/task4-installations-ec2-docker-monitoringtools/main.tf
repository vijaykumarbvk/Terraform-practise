provider "aws" {
  region = "us-east-1" # Change to your preferred region
}

# Use the default VPC and Subnet for simplicity
data "aws_vpc" "default" {
  default = true
}

# Security Group for App Server (Server 1)
resource "aws_security_group" "app_sg" {
  name        = "app-server-sg"
  description = "Allow Node Exporter traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In production, restrict this to the Monitoring Server's IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Monitoring Server (Server 2)
resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-server-sg"
  description = "Allow Grafana, Prometheus, and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Node Exporter (Self)"
    from_port   = 9100
    to_port     = 9100
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

# Fetch the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Server 1: App Server (Node Exporter Only)
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = file("${path.module}/install_app_server.sh")

  tags = {
    Name = "App-Server"
  }
}

# Server 2: Monitoring Server (Docker, Prometheus, Grafana, Node Exporter)
resource "aws_instance" "monitoring_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]

  # Pass the App Server's private IP into the user_data template
  user_data = templatefile("${path.module}/install_monitoring_server.sh.tpl", {
    app_server_ip = aws_instance.app_server.private_ip
  })

  tags = {
    Name = "Monitoring-Server"
  }
}

output "grafana_url" {
  value = "http://${aws_instance.monitoring_server.public_ip}:3000"
}

output "prometheus_url" {
  value = "http://${aws_instance.monitoring_server.public_ip}:9090"
}