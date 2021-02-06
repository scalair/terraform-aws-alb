# Terraform AWS ALB

This modules creates an Application Load Balancer with a security group and optional Route53 alias records.

## Usage example

```hcl
module "alb" {
    name                = "alb-dev"
    security_group_name = "sg-alb-dev"

    vpc_id      = "vpc-id-123456"
    subnets_ids = ["subnet-1", "subnet-2"]

    aliases         = ["mydomain.example.com"]
    route53_zone_id = "ABCDEFGH1234"

    idle_timeout = 60
    internal     = false
    
    listener_ssl_policy_default = "ELBSecurityPolicy-TLS-1-2-2017-01"

    http_listeners = [
        {
            port        = 80
            protocol    = "HTTP"
            action_type = "redirect"
            redirect = {
                port        = "443"
                protocol    = "HTTPS"
                status_code = "HTTP_301"
            }
        }
    ]

    https_listeners = [
        {
            port               = 443
            protocol           = "HTTPS"
            certificate_arn    = "arn:aws:iam::123456789012:certificate/123456789012"
        }
    ]

    https_listener_rules = [
        {
            priority = 1

            actions = [{
                type         = "fixed-response"
                content_type = "text/plain"
                status_code  = 200
                message_body = "fixed response"
            }]

            conditions = [{
                http_headers = [{
                    http_header_name = "Custom-Header"
                    values           = ["custom-value"]
                }]
            }]
        }
    ]

    target_groups = [
        {
            name                 = "h1"
            backend_protocol     = "HTTP"
            backend_port         = 80
            health_check = {
                enabled             = true
                interval            = 30
                path                = "/healthz"
                port                = "traffic-port"
                healthy_threshold   = 3
                unhealthy_threshold = 3
                timeout             = 6
                protocol            = "HTTP"
                matcher             = "200-399"
            }
        }
    ]

    security_groups = [
    {
        name = "alb-dev-sg"
            ingress = [
                {
                    from_port   = 80
                    to_port     = 80
                    protocol    = "tcp"
                    description = "HTTP"
                    cidr_blocks = "0.0.0.0/0"
                },
                {
                    from_port   = 443
                    to_port     = 443
                    protocol    = "tcp"
                    description = "HTTPS"
                    cidr_blocks = "0.0.0.0/0"
                }
            ]
            egress = [
                { rule = "all-all", cidr_blocks = "0.0.0.0/0" }
            ]
        }
    ]

    tags = {
        Environment = "dev"
    }

}
```
