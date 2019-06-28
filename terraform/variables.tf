variable "cidr_office" {
  default = ""
}
variable "owner" {
  default = ""
}
variable "site_id" {
  default = "dev"
}
variable "aws_profile" {
  default = "dev"
}
variable "aws_region" {
  default = "ap-northeast-1"
}
provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

locals {
  vpc_cidr_block = "10.1.0.0/21"
  vpc_az = [
    "a",
    "c",
    "d"
  ]
  vpc_subnet_public_cidr_blocks = {
    "a" = "10.1.0.0/24"
    "c" = "10.1.1.0/24"
    "d" = "10.1.2.0/24"
  }
  vpc_subnet_private_cidr_blocks = {
    "a" = "10.1.3.0/24"
    "c" = "10.1.4.0/24"
    "d" = "10.1.5.0/24"
  }
}
