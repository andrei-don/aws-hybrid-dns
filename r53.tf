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