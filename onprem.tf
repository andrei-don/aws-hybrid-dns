resource "aws_security_group" "onprem" {
  name        = "onprem_sg"
  description = "Allow ssh, dns traffic and all outbound traffic"
  vpc_id      = aws_vpc.onprem.id

  tags = {
    Name = "onprem_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "onprem_outbound" {
  security_group_id = aws_security_group.onprem.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_ingress_rule" "onprem_inbound_ssh" {
  security_group_id = aws_security_group.onprem.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "onprem_inbound_http" {
  security_group_id = aws_security_group.onprem.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "onprem_inbound_https" {
  security_group_id = aws_security_group.onprem.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "onprem_inbound_dns_tcp" {
  security_group_id = aws_security_group.onprem.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 53
  to_port     = 53
}

resource "aws_vpc_security_group_ingress_rule" "onprem_inbound_dns_udp" {
  security_group_id = aws_security_group.onprem.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "udp"
  from_port   = 53
  to_port     = 53
}

resource "aws_vpc_security_group_ingress_rule" "onprem_inbound_icmp" {
  security_group_id = aws_security_group.onprem.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "icmp"
  from_port   = -1
  to_port     = -1
}

resource "aws_vpc_security_group_ingress_rule" "onprem_self" {
  security_group_id = aws_security_group.onprem.id

  ip_protocol                  = -1
  referenced_security_group_id = aws_security_group.onprem.id
}

resource "aws_vpc_endpoint" "onprem_ssm" {
  vpc_id              = aws_vpc.onprem.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  subnet_ids          = [aws_subnet.onprem.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.onprem.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "onprem_ec2messages" {
  vpc_id              = aws_vpc.onprem.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  subnet_ids          = [aws_subnet.onprem.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.onprem.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "onprem_ssmmessages" {
  vpc_id              = aws_vpc.onprem.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  subnet_ids          = [aws_subnet.onprem.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.onprem.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "onprem_s3" {
  vpc_id          = aws_vpc.onprem.id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.onprem.id]
}

resource "aws_instance" "onpremapp" {
  ami                    = data.aws_ami.this.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  subnet_id              = aws_subnet.onprem.id
  vpc_security_group_ids = [aws_security_group.onprem.id]
  tags = {
    Name = "onprem-app"
  }
}

resource "aws_instance" "onpremdns" {
  ami                    = data.aws_ami.this.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  subnet_id              = aws_subnet.onprem.id
  vpc_security_group_ids = [aws_security_group.onprem.id]
  user_data              = templatefile("${path.module}/user_data/user_data.tftpl", { r53_resolver = "10.6.0.2", onpremapp_privateip = aws_instance.onpremapp.private_ip, inbound_endpoint_a = local.inbound_endpoint_ips[0], inbound_endpoint_b = local.inbound_endpoint_ips[1] })
  tags = {
    Name = "onprem-dns"
  }
}







