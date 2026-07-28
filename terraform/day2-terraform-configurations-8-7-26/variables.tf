variable "cidr_block" {
    description = "the cidr block for the vpc"
    type = string
    default = ""  
}

variable "tag" {
    description = "the tag for vpc"
    type = string
    default = ""
}

variable "cidr_block_vpc-2" {
    description = "the cidr block for the vpc"
    type = string
    default = ""  
}

variable "cidr_block_subnet" {
    description = "the cidr block for the subnet"
    type = string
    default = ""
}

variable "tag_subnet" {
  description = "the tag for the subnet tag"
  type = string
  default = "vijay"
}