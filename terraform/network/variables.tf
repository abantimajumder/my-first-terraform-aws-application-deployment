variable "project_name" {
  type = string
  default = "terraform-aws-application"
}
variable "aws_vpc_name" {
  type = string
  default = "main-vpc"
}

variable "vpc_cidr_range" {
  type = string
  default = "10.0.0.0/16"
}

variable "Environment" {
  type = string
  default = "dev"
}

variable "availability_zone_subnet" {
    type = list(string)
    description = "availability zone for subnet"
}

variable "web_public_subnets" {
  description = "CIDR blocks for web public subnets"
  type        = list(string)
}

variable "web_private_subnets" {
  description = "CIDR blocks for web private subnets"
  type        = list(string)
}

variable "app_private_subnets" {
  description = "CIDR blocks for app private subnets"
  type        = list(string)
}

variable "db_private_subnets" {
  description = "CIDR blocks for db private subnets"
  type        = list(string)
}





###############
# sg variable
###############

variable "sg_frontend_alb_name" {
  type = string
  default = "frontend-alb-sg"
  description = "frontend alb name "
}

variable "sg_backend_alb_name" {
  type = string
  description = "backend-alb-sg"
  default = "frontend-alb-sg"
}

variable "sg_frontend_ec2" {
  type = string
  description = "sg for frontend ec2"
  default = "frontend-ec2-sg"
}

variable "sg_backend_ec2" {
  type = string
  description = "sg for backend ec2"
  default = "backend-ec2-sg"
}
