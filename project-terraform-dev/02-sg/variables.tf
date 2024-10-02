variable "project_name" {
  default = "project"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project = "project"
    Environment = "dev"
    Terraform = "true"
  }
}

variable "db_sg_description" {
  default = "SG for DB MySQL Instances"
}