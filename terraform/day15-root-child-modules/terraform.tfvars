aws_region = "us-east-1"

cidr = "10.0.0.0/16"

instance_type = "t2.micro"
ami = "ami-0b826bb6d96d2afe4"

# Security Group Configuration
sg_name        = "app-web-sg"
sg_description = "Security group for web servers allowing HTTP, HTTPS, and SSH"

ingress_rules = [
  {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "Allow SSH from VPN"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # Example: Only allow SSH from internal network
  }
]

# Common Tags
tags = {
  Environment = "Development"
  Project     = "WebApp"
  ManagedBy   = "Terraform"
}