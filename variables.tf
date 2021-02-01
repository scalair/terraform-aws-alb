variable "name" {
  description = "The resource name and Name tag of the load balancer."
  type        = string
}

variable "vpc_id" {
  description = "VPC id where the load balancer and other resources will be deployed."
  type        = string
}

variable "subnets_ids" {
  description = "A list of subnet IDs to attach to the LB."
  type        = list(string)
}

variable "http_listeners" {
  description = "A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target_group_index."
  type        = list
  default     = []
}

variable "https_listeners" {
  description = "A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy (defaults to ELBSecurityPolicy-2016-08), target_group_index."
  type        = list
  default     = []
}

variable "https_listener_rules" {
  description = "A list of HTTPS Listener rules."
  type        = list
  default     = []
}

variable "target_groups" {
  description = "A list of target groups."
  type        = list
  default     = []
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle."
  type        = number
  default     = 60
}

variable "internal" {
  description = "Boolean determining if the load balancer is internal or externally facing."
  type        = bool
  default     = false
}

variable "listener_ssl_policy_default" {
  description = "The security policy if using HTTPS externally on the load balancer."
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "security_group_name" {
  description = "Name of the security group associated to the load balancer."
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules attached to the security group."
  type        = list
  default     = []
}

variable "egress_rules" {
  description = "List of egress rules attached to the security group."
  type        = list
  default     = []
}

variable "aliases" {
  description = "Alias records list for the load balancer."
  type        = list(string)
  default     = []
}

variable "route53_zone_id" {
  description = "The ID of the hosted zone to contain this record."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
