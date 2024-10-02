terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.57"
    }
  }
  backend "s3" {
    bucket = "devops-remote-state"
    key    = "project-dev-eks"
    region = "us-east-1"
    dynamodb_table = "devops-locking"
  }
}

#provide authentication here
provider "aws" {
  region = "us-east-1"
}