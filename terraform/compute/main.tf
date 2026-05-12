#######################
# frontend load balancer
#######################

resource "aws_lb" "frontend_alb" {
  name               = var.frontend_alb_name
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


##############################
#forntend lb target group
#############################

# Frontend Target Group
resource "aws_lb_target_group" "frontend_lb_tg" {
  name     = "${var.project_name}-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher            = "200"
    path               = "/"
    port               = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_name}-frontend-tg"
    Environment = var.environment
  }
}

#########################
# Frontend lb Listener
#########################

resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_lb_tg.arn
  }
}
###############################
# # Frontend Auto Scaling Group
###############################

resource "aws_autoscaling_group" "frontend-asg" {
  name                = "${var.project_name}-frontend-asg"
  vpc_zone_identifier = data.terraform_remote_state.network.outputs.web_private_id
  desired_capacity    = var.frontend_desired_capacity
  max_size           = var.frontend_max_size
  min_size           = var.frontend_min_size

  launch_template {
    id      = aws_launch_template.frontend_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.frontend_lb_tg.arn]

  tag {
    key                 = "Name"
    value              = "${var.project_name}-frontend"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value              = var.environment
    propagate_at_launch = true
  }
}

#############################
# Frontend Launch Template
############################
resource "aws_launch_template" "frontend_launch_template" {
  name_prefix   = "${var.project_name}-frontend-launch-template"
  image_id      = local.frontend_ami_id
  instance_type = var.frontend_instance_type
  key_name      = var.frontend_key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [data.terraform_remote_state.network.outputs.frontend_sg_ec2_id]
  }

  user_data = base64encode(templatefile("${path.module}/frontend_user_data.sh", {
    project_name = var.project_name
    backend_alb_dns = aws_lb.frontend_alb.dns_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-frontend"
      Environment = var.environment
    }
  }
}

#######################
# backend load balancer
#######################

resource "aws_lb" "backend_alb" {
  name               = var.backend_alb_name
  internal           = true
  load_balancer_type = "application"
  security_groups = [data.terraform_remote_state.network.outputs.backend_alb_sg_id]
  subnets            = data.terraform_remote_state.network.outputs.app_private_id

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-backend-alb"
    Environment = var.environment
  }
}


####################################
#target group for backend lb
####################################

resource "aws_lb_target_group" "backend_lb_tg" {
  name     = "${var.project_name}-backend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher            = "200"
    path               = "/"
    port               = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_name}-backend-tg"
    Environment = var.environment
  }
}

#############################################
# auto scaling group for backend ec2 instances
#############################################
resource "aws_autoscaling_group" "backend-asg" {
  name                = "${var.project_name}-backend-asg"
  vpc_zone_identifier = data.terraform_remote_state.network.outputs.app_private_id
  desired_capacity    = var.backend_desired_capacity
  max_size           = var.backend_max_size
  min_size           = var.backend_min_size

  launch_template {
    id      = aws_launch_template.backend_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.backend_lb_tg.arn]

  tag {
    key                 = "Name"
    value              = "${var.project_name}-frontend"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value              = var.environment
    propagate_at_launch = true
  }
}

###########################################
# backend ec2 launch template
###########################################

resource "aws_launch_template" "backend_launch_template" {
  name_prefix   = "${var.project_name}-backend-launch-template"
  image_id      = local.backend_ami_id
  instance_type = var.backend_instance_type
  key_name      = var.backend_key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [data.terraform_remote_state.network.outputs.backend_sg_ec2_id]
  }

  user_data = base64encode(templatefile("${path.module}/backend_user_data.sh", {
    project_name = var.project_name
    db_host      = data.terraform_remote_state.database.outputs.rds_address
    db_username  = data.terraform_remote_state.database.outputs.rds_username
    db_password  = data.terraform_remote_state.database.outputs.rds_password
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-backend"
      Environment = var.environment
    }
  }
}

# EC2 Key Pair
resource "aws_key_pair" "frontend" {
  key_name   = "frontend-key"
  public_key = file("keys/frontend.pub")
}

resource "aws_key_pair" "backend" {
  key_name   = "backend-key"
  public_key = file("keys/backend.pub")
}

######################################
# backend alb listener
#####################################

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_lb_tg.arn
  }
}