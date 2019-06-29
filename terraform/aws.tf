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