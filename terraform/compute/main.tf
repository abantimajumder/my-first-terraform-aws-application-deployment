#######################
# frontend load balancer
#######################

resource "aws_lb" "frontend_alb" {
  name               = var.front-alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups = [data.terraform_remote_state.network.outputs.frontend_alb_sg_id]
  subnets            = data.terraform_remote_state.network.outputs.web_public_id

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-frontend-alb"
    Environment = var.environment
  }
}


#######################
# backend load balancer
#######################



