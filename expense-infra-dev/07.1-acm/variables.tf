variable "project_name" {
  default = "project"
}

variable "project" {
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

variable "zone_id" {
  default = "id"
}