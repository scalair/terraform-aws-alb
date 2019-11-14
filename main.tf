locals {
  bucket_count = var.logging_enabled ? 1 : 0
}

resource "aws_security_group" "alb_sg" {
  name        = var.security_group_name
  description = "ALB security group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "http_ingress" {
  security_group_id = aws_security_group.alb_sg.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https_ingress" {
  security_group_id = aws_security_group.alb_sg.id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "backend_egress" {
  security_group_id = aws_security_group.alb_sg.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]
}

data "aws_elb_service_account" "main" {
  count = local.bucket_count
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count = local.bucket_count

  bucket = aws_s3_bucket.bucket[local.bucket_count - 1].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["s3:PutObject"],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket[local.bucket_count - 1].id}/*",
      "Principal": {
        "AWS": ["${data.aws_elb_service_account.main[local.bucket_count - 1].arn}"]
      }
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "bucket" {
  count = local.bucket_count

  bucket = var.log_bucket_name
  acl    = "private"
  region = var.vpc_state_region

  versioning {
    enabled = false
  }

  force_destroy = true

  tags = var.tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "4.1.0"

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
  log_bucket_name                  = aws_s3_bucket.bucket[local.bucket_count - 1].id
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