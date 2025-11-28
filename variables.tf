variable "aws_region" {
    default = "us-east-1"
}

variable "project_name" {
    description = "Project Name"
    type = string
    default = "strapi-ubuntu"
}

variable "instance_type" {
    description = "EC2 Instance Type"
    type = string
    default = "t2.medium"
}

variable "key_name" {
    description = "Existing Ec2 Key Pair"
    type = string
}

variable "ssh_allowed_cidr" {
    type = string
    default = "0.0.0.0/0"
}