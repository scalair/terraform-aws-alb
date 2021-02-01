module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = var.security_group_name
  description = "${var.security_group_name} ALB security group"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = var.ingress_rules
  egress_with_cidr_blocks  = var.egress_rules

  tags = var.tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name               = var.name
  load_balancer_type = "application"

  vpc_id          = var.vpc_id
  security_groups = list(module.security_group.this_security_group_id)
  subnets         = var.subnets_ids

  http_tcp_listeners   = var.http_listeners
  https_listeners      = var.https_listeners
  https_listener_rules = var.https_listener_rules
  target_groups        = var.target_groups

  idle_timeout                = var.idle_timeout
  internal                    = var.internal
  listener_ssl_policy_default = var.listener_ssl_policy_default

  tags              = var.tags
  lb_tags           = var.tags
  target_group_tags = var.tags
}

# Route53 alias records are created if var.aliases is not empty.
resource "aws_route53_record" "alb_record" {
  for_each = toset(var.aliases)

  name    = each.value
  zone_id = var.route53_zone_id
  type    = "A"

  alias {
    name                   = module.alb.this_lb_dns_name
    zone_id                = module.alb.this_lb_zone_id
    evaluate_target_health = true
  }
}
