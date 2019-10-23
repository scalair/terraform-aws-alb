output "dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.alb.dns_name
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = module.alb.http_tcp_listener_arns
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value       = module.alb.http_tcp_listener_ids
}

output "https_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created."
  value       = module.alb.https_listener_arns
}

output "https_listener_ids" {
  description = "The IDs of the load balancer listeners created."
  value       = module.alb.https_listener_ids
}

output "load_balancer_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
  value       = module.alb.load_balancer_arn_suffix
}

output "load_balancer_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.alb.load_balancer_id
}

output "load_balancer_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = module.alb.load_balancer_zone_id
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = module.alb.target_group_arns
}

output "target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value       = module.alb.target_group_arn_suffixes
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = module.alb.target_group_names
}

output "load_balancer_security_group_id" {
  description = "Security Group ID associated to the Load Balancer"
  value       = aws_security_group.alb_sg.id
}

output "load_balancer_target_groups_backend_port" {
  value = var.target_groups.*.backend_port
}