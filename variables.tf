variable "vpc_cidr_block" {
    type = string
    description = "cidr_block VPC"
    default = "192.168.0.0/16"
}

variable "vpc_name" {
    type = string
    description = "VPC name"
    default = "VPC"
}

variable "db_name" {
    type = string
    description = "Postgres Database Name"
}

variable "db_user" {
    type = string
    description = "Postgres Database User"
}

variable "db_password" {
    type = string
    description = "Postgres Databse Password"
}

variable "app_instance_type" {
    type = string
    description = "Instance type of Node application machine"
    default = "t2.micro"
}

variable "db_instance_type" {
    type = string
    description = "Instance type of Database machine"
    default = "t2.micro"
}

variable "project_name" {
    type = string
    description = "Project Name"
}

variable "app_src_dir" {
    type = string
    description = "Application Source Directory"
}