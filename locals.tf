locals {
  inbound_endpoint_ips = [for ip in aws_route53_resolver_endpoint.inbound.ip_address : ip.ip]
}