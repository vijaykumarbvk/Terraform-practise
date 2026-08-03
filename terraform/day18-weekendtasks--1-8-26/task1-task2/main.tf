# task1: Create a reusable Terraform child module that provisions a production-ready MySQL RDS instance with read replica encrypted storage,
#  automated backups, a DB subnet group, and security group.
#  The root module should invoke this child module and use its outputs to configure the application servers.

# this is from AWS vpc Terraform module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
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

# this is from AWS RDS Terraform module

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "demodb"

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.medium"
  allocated_storage = 5

  # ADD THIS LINE TO ENABLE BACKUPS
  backup_retention_period = 1

#   Tell AWS to apply the backup change right now!
  apply_immediately       = true

  db_name  = "demodb"
  username = "user"
  password_wo = "MyS3curePassw0rd!"
  password_wo_version = 1
  manage_master_user_password = false
  port     = "3306"

  iam_database_authentication_enabled = true

  # UPDATED: Using the default security group created by the VPC module
#   vpc_security_group_ids = [module.vpc.default_security_group_id]
vpc_security_group_ids = [aws_security_group.rds_sg.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  create_db_subnet_group = true
  # UPDATED: Passing the private subnets dynamically from the VPC module
  subnet_ids             = module.vpc.private_subnets

  family = "mysql8.0"
  major_engine_version = "8.0"
  deletion_protection = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}

# READ REPLICA (NEW)

module "replica" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "demodb-replica"

  # This tells AWS to make this a replica of your primary DB
  replicate_source_db = module.db.db_instance_identifier

  # ADD THESE TWO LINES TO FIX THE ERROR
  engine         = "mysql"
  engine_version = "8.0"

  instance_class    = "db.t3.medium"
  port              = "3306"
  storage_encrypted = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  family               = "mysql8.0"
  major_engine_version = "8.0"

  iam_database_authentication_enabled = true
  # Explicitly disable password management on the replica too
  manage_master_user_password = false

  tags = {
    Environment = "prod"
  }
}

# APP SERVER (NEW - Consuming DB Outputs)

resource "aws_security_group" "app_sg" {
  name        = "my-app-server-sg"
  description = "Application server security group"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "My-App-Server-SG"
    Environment = "dev"
  }
}

resource "aws_instance" "app_server" {
  ami                    = "ami-02b64aa047cb5edf5" # Ensure this AMI is valid for your AWS region
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  
  # Placing the app server in a private subnet
  subnet_id     = module.vpc.private_subnets[0]

  # Injecting the DB and Redis endpoints as environment variables for your application code to use
  user_data = <<-EOF
              #!/bin/bash
              echo "export DB_WRITE_HOST=${module.db.db_instance_endpoint}" >> /etc/environment
              echo "export DB_READ_HOST=${module.replica.db_instance_endpoint}" >> /etc/environment
              echo "export REDIS_HOST=${module.redis.replication_group_primary_endpoint_address}" >> /etc/environment
              echo "export REDIS_PORT=${module.redis.replication_group_port}" >> /etc/environment
              EOF

  tags = {
    Name = "My-App-Server"
  }
}


# task-2:   The application team wants to improve performance by introducing Redis caching. 
# Design a reusable Terraform child module that provisions an ElastiCache Redis replication group across private subnets with automatic failover enabled. 
# The EC2 application module should consume the Redis endpoint output from this module without any hardcoded values.

module "redis" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "1.11.0"

  replication_group_id        = "app-redis-rg"
  engine                      = "redis"
  engine_version              = "7.0"
  node_type                   = "cache.t3.micro"
  port                        = 6379
  automatic_failover_enabled  = true
  multi_az_enabled            = true
  num_cache_clusters          = 2
  create_parameter_group      = true
  parameter_group_family      = "redis7"
  maintenance_window          = "sun:02:00-sun:06:00"
  apply_immediately           = true

  vpc_id = module.vpc.vpc_id

  security_group_rules = {
    app_access = {
      description               = "Allow Redis access from the app server"
      referenced_security_group_id = aws_security_group.app_sg.id
      from_port                 = 6379
      to_port                   = 6379
      protocol                  = "tcp"
    }
  }

  subnet_ids = module.vpc.private_subnets

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
