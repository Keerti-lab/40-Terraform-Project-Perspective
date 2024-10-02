variable "instance_names" {
  type        = map
  # default     = {
  #   db-dev = "t3.small"
  #   backend-dev = "t3.micro"
  #   frontend-dev = "t3.micro"
  # }
}

variable "environment" {
  # default = "dev"
}

variable "common_tags" {
    type = map
    default = {
      Project = "project"
      Terraform = "true"
    }
}

variable "domain_name" {
    default = "mdom.fun"
}

variable "zone_id" {
    default = "id"
}