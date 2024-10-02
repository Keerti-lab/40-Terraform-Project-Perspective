variable "ami_id" {
    type = string
    default = "ami-id"
}

variable "security_group_ids" {
    type = list
    default = ["sg-id"] #replace with your SG ID.
}

variable "instance_type" {
    default = "t3.micro"
    type = string
}

variable "tags" {
    type = map
    default = {} # this means empty, so not mandatory
}