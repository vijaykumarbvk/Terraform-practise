resource "aws_instance" "name" {
    ami = "ami-002192a70217ac181"
    instance_type = "t2.micro"
    tags = {
        Name = "dev-2"
    }
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "vj-prac-terraform-day4-app"
  tags = {
    Name        = "dev-app-bucket"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
