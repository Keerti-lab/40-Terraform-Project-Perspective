terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.48.0"
    }
  }
  backend "s3" {
    bucket = "devops-remote-state"
    key    = "project-dev-vpc"
    region = "us-east-1"
    dynamodb_table = "devops-locking"
  }
}

#provide authentication here
provider "aws" {
  region = "us-east-1"
}