resource "aws_instance" "db" {
    ami = "ami-id"
    vpc_security_group_ids = ["sg-id"]
    instance_type = lookup(var.instance_type, terraform.workspace)
}