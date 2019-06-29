terraform {
  backend "s3" {
    profile = "dev"
    region  = "ap-northeast-1"
    bucket  = "aws-fargate-example-innossh-github-com"
    key     = "terraform/dev-postgresql.tfstate"
  }
}
