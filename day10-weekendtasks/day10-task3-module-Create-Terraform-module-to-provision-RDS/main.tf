#this vpc module will create a VPC with 2 public and 2 private subnets in 2 availability zones, and a NAT gateway for the private subnets to access the internet
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
    azs             = ["us-east-1a", "us-east-1b"]
    public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
    enable_nat_gateway = true
    single_nat_gateway = true

}
#security group for RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "my-rds-security-group"
  description = "Allow access to the RDS instance from within the VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

}


#this is the RDS module that will create a MySQL RDS instance in the private subnets created by the VPC module, and will use the security group created for the RDS instance
module "rds" {
  source = "terraform-aws-modules/rds/aws" #this source coming from terraform registry, this module will create a RDS instance with the specified parameters
  version = "~> 5.0"

  identifier = "my-rds-instance"
  engine     = "mysql"
  engine_version = "8.0"
  major_engine_version = "8.0"
  family = "mysql8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  username = "admin"
  password = "admin123  "
  vpc_security_group_ids = [aws_security_group.rds_sg.id] #this will use the security group created for the RDS instance
  create_db_subnet_group = true #this will create a DB subnet group for the RDS instance
  subnet_ids = module.vpc.private_subnets  #ths will use the private subnets created by the VPC module
  publicly_accessible = false
  
  skip_final_snapshot = true

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}