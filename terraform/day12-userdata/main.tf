resource "aws_instance" "name" {
    ami = "ami-0b826bb6d96d2afe4"
    instance_type = "t2.micro"
    user_data = file("userdata.sh")
    tags = {
        Name = "vj"
    }
  
}
