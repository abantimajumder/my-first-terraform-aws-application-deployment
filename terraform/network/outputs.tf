output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.main.id
}

output "web_public_id" {
  description = "web public subnet id"
  value = aws_subnet.web_public.id
}

output "web_private_id" {
  description = "web private subnet id"
  value = aws_subnet.web_private.id
}

output "app_private_id" {
  description = "app private subnet id"
  value = aws_subnet.app_private.id
}

output "db_private_id" {
  description = "db private subnet id"
  value = aws_subnet.db_private.id
}

output "frontend_alb_sg_id" {
  description = "ID of the frontend ALB security group"
  value = aws_security_group.sg_frontend_alb.id
}

output "backend_alb_sg_id" {
  description = "ID of the backend ALB security group"
  value = aws_security_group.sg_backend_alb.id
}

output "frontend_sg_ec2_id" {
  description = "ID of the frontend ec2 security group"
  value = aws_security_group.sg_frontend_ec2.id
}

output "backend_sg_ec2_id" {
  description = "ID of the backend ec2 security group"
  value = aws_security_group.sg_backend_ec2.id
}

output "rds_sg_id" {
  description = "id of rds security group"
  value = aws_security_group.rds.id
}

output "web_public_subnet_rt_id" {
  description = "route table if for web public subnet"
  value = aws_route_table.web_public_subnet_rt.id
}

output "web_private_subnet_rt_id" {
  description = "route table if for web private subnet"
  value = aws_route_table.web_private_subnet_rt.id
}

output "app_private_subnet_rt_id" {
  description = "route table if for app private subnet"
  value = aws_route_table.app_private_subnet_rt.id
}

output "db_private_subnet_rt_id" {
  description = "route table if for db private subnet"
  value = aws_route_table.db_private_subnet_rt.id
}

