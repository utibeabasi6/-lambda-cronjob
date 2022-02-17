terraform {
  backend "s3" {
    bucket = var.state_bucket
    key    = "terraform.tfstate"
    region = var.aws_region
  }
}

provider "aws" {
  region = var.aws_region
}