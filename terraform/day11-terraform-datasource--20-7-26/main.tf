
data "aws_subnet" "name" {

  filter {
name = "tag:Name"
values = ["sample"]
}

}

data "aws_security_group" "selected" {
    filter {
        name   = "tag:Name"
        values = ["my-security-group"] #fetch the security group with the tag Name=my-security-group
    }
}


data "aws_ami" "amzlinux-backend" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-gp2" ]
  }
             filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
        filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}
resource "aws_instance" "name" {
    ami = data.aws_ami.amzlinux-backend.id
    instance_type = "t2.micro"
    subnet_id = data.aws_subnet.name.id
    vpc_security_group_ids = [ data.aws_security_group.selected.id ]
      
}

# here datasource is used to already reuse/recall existing resources whether it may be created manual or terraform