output "frontend_alb_dns_name" {
  description = "DNS name of the frontend ALB"
  value       = aws_lb.frontend_alb.dns_name
}

output "frontend_alb_arn" {
  description = "ARN of the frontend ALB"
  value       = aws_lb.frontend_alb.arn
}

output "frontend_target_group_arn" {
  description = "ARN of the frontend target group"
  value       = aws_lb_target_group.frontend_lb_tg.arn
}

output "backend_alb_dns_name" {
  description = "DNS name of the backend ALB"
  value       = aws_lb.backend_alb.dns_name
}

output "backend_alb_arn" {
  description = "ARN of the backend ALB"
  value       = aws_lb.backend_alb.arn
}

output "backend_target_group_arn" {
  description = "ARN of the backend target group"
  value       = aws_lb_target_group.backend_lb_tg.arn
}

output "frontend_asg_name" {
  description = "The name of the frontend Auto Scaling Group"
  value       = aws_autoscaling_group.frontend-asg.name
}

output "backend_asg_name" {
  description = "The name of the backend Auto Scaling Group"
  value       = aws_autoscaling_group.backend-asg.name
}

output "frontend_key_name" {
  description = "The name of the frontend key pair"
  value       = aws_key_pair.frontend.key_name
}

output "backend_key_name" {
  description = "The name of the backend key pair"
  value       = aws_key_pair.backend.key_name
} 