provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "terraform-estado-damian"
    key    = "infraestructura/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}
