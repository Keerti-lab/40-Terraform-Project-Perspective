variable "image_id" {
  type        = string #optional
  default     = "ami-id" #optional
  description = "RHEL-9 AMI ID" #optional
}

variable "instance_type" {
    default = "t3.micro"
    type = string
}

variable "instance_name" {
    default = "backend"
}