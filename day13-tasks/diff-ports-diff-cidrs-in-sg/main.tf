provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

locals {
  ingress_rules = [
    {
      description = "SSH access from a trusted CIDR"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["203.0.113.0/24"]
    },
    {
      description = "HTTP access from a second CIDR"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["198.51.100.0/24"]
    },
    {
      description = "HTTPS access from a third CIDR"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["192.0.2.0/24"]
    },
  ]
}

resource "aws_security_group" "diff_ports_diff_cidrs" {
  name        = "diff-ports-diff-cidrs-sg"
  description = "Security group with different ports and CIDR blocks"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = local.ingress_rules

    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "diff-ports-diff-cidrs-sg"
  }
}
