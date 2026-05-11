variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

###########################
# alb variables
#########################

variable "front-alb_name" {
  type = string
  description = "alb for frontend"
  default = "front-alb"
}