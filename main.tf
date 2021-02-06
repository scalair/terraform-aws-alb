module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  for_each = { for i, v in var.security_groups : i => v }

  name        = each.value.name
  description = "ALB ${var.name} Security Group"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = lookup(each.value, "ingress", [])
  egress_with_cidr_blocks  = lookup(each.value, "egress", [])

  tags = var.tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name               = var.name
  load_balancer_type = "application"

  vpc_id          = var.vpc_id
  security_groups = [for sg in module.security_group : sg.this_security_group_id]
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

locals {
  target_group_arns = { for i, n in module.alb.target_group_names : n => module.alb.target_group_arns[i] }
  target_group_attachments = flatten([
    for i, group in var.target_groups : [
      for i, id in lookup(group, "target_ids", []) : {
        target_group_arn = local.target_group_arns[group.name]
        target_id        = id
        port             = group.backend_port
      }
    ]
  ])
}

resource "aws_lb_target_group_attachment" "alb_tg_attachment" {
  for_each = { for i, v in local.target_group_attachments : i => v }

  target_group_arn = each.value.target_group_arn
  target_id        = each.value.target_id
  port             = each.value.port
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
