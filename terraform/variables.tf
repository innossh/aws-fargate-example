variable "cidr_office" { description = "CIDR allowed connecting to resources, like your office's IP" }
variable "s3_bucket_name" { description = "Your S3 bucket name" }

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
