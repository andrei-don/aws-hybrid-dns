resource "aws_route53_zone" "cloud" {
  name = "cloud.example.com"

  vpc {
    vpc_id = aws_vpc.cloud.id
  }
}

resource "aws_route53_record" "cloud" {
  zone_id = aws_route53_zone.cloud.zone_id
  name    = "web.cloud.example.com"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.cloudapp.private_ip]
}

resource "aws_route53_resolver_endpoint" "inbound" {
  name      = "cloud-inbound"
  direction = "INBOUND"

  security_group_ids = [
    aws_security_group.cloud.id
  ]

  ip_address {
    subnet_id = aws_subnet.cloud_a.id
  }

  ip_address {
    subnet_id = aws_subnet.cloud_b.id
  }
}