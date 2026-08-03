# variables.tf
variable "my_ip" {
  description = "Your local IP for SSH/Jenkins UI access, e.g. 1.2.3.4/32"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH"
  type        = string
}