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
    Component = "app-alb"
  }
}

variable "zone_name" {
  default = "mdom.fun"
}