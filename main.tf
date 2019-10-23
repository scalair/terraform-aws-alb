resource "aws_security_group" "alb_sg" {
  name        = var.security_group_name
  description = "ALB security group for ${var.security_group_name}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "http_ingress" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "https_ingress" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "backend_egress" {
  for_each = toset(var.target_groups.*.backend_port)

  type        = "egress"
  from_port   = each.value
  to_port     = each.value
  protocol    = "tcp"
  cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks

  security_group_id = aws_security_group.alb_sg.id
}

module "alb" {
  source = "github.com/terraform-aws-modules/terraform-aws-alb?ref=v4.1.0"

  load_balancer_name = var.load_balancer_name
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnets
  security_groups    = list(aws_security_group.alb_sg.id)

  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  extra_ssl_certs                  = var.extra_ssl_certs
  https_listeners                  = var.https_listeners
  https_listeners_count            = var.https_listeners_count
  http_tcp_listeners               = var.http_tcp_listeners
  http_tcp_listeners_count         = var.http_tcp_listeners_count
  idle_timeout                     = var.idle_timeout
  ip_address_type                  = var.ip_address_type
  listener_ssl_policy_default      = var.listener_ssl_policy_default
  load_balancer_is_internal        = var.load_balancer_is_internal
  load_balancer_create_timeout     = var.load_balancer_create_timeout
  load_balancer_delete_timeout     = var.load_balancer_delete_timeout
  load_balancer_update_timeout     = var.load_balancer_update_timeout
  logging_enabled                  = var.logging_enabled
  log_bucket_name                  = var.log_bucket_name
  log_location_prefix              = var.log_location_prefix
  target_groups                    = var.target_groups
  target_groups_count              = var.target_groups_count
  target_groups_defaults           = var.target_groups_defaults

  tags = var.tags
}

resource "aws_route53_record" "alb_record" {
  for_each = toset(var.aliases)

  name    = each.value
  zone_id = var.route_53_zone_id
  type    = "A"

  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.load_balancer_zone_id
    evaluate_target_health = true
  }
}