resource "aws_security_group" "cloud" {
  name        = "cloud_sg"
  description = "Allow ssh, dns traffic and all outbound traffic"
  vpc_id      = aws_vpc.cloud.id

  tags = {
    Name = "cloud_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "cloud_outbound" {
  security_group_id = aws_security_group.cloud.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_ingress_rule" "cloud_inbound_ssh" {
  security_group_id = aws_security_group.cloud.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "cloud_inbound_http" {
  security_group_id = aws_security_group.cloud.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "cloud_inbound_https" {
  security_group_id = aws_security_group.cloud.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "cloud_inbound_dns_tcp" {
  security_group_id = aws_security_group.cloud.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 53
  to_port     = 53
}

resource "aws_vpc_security_group_ingress_rule" "cloud_inbound_dns_udp" {
  security_group_id = aws_security_group.cloud.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "udp"
  from_port   = 53
  to_port     = 53
}

resource "aws_vpc_security_group_ingress_rule" "cloud_inbound_icmp" {
  security_group_id = aws_security_group.cloud.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "icmp"
  from_port   = -1
  to_port     = -1
}

resource "aws_vpc_security_group_ingress_rule" "cloud_inbound_higher_ports_tcp" {
  security_group_id = aws_security_group.cloud.id

  cidr_ipv4   = var.onprem_vpc_cidr
  ip_protocol = "tcp"
  from_port   = 1024
  to_port     = 65535
}

resource "aws_vpc_security_group_ingress_rule" "cloud_inbound_higher_ports_udp" {
  security_group_id = aws_security_group.cloud.id

  cidr_ipv4   = var.onprem_vpc_cidr
  ip_protocol = "udp"
  from_port   = 1024
  to_port     = 65535
}

resource "aws_vpc_security_group_ingress_rule" "cloud_self" {
  security_group_id = aws_security_group.cloud.id

  ip_protocol                  = -1
  referenced_security_group_id = aws_security_group.cloud.id
}

resource "aws_vpc_endpoint" "cloud_ssm" {
  vpc_id              = aws_vpc.cloud.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  subnet_ids          = [aws_subnet.cloud_a.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.cloud.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "cloud_ec2messages" {
  vpc_id              = aws_vpc.cloud.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  subnet_ids          = [aws_subnet.cloud_a.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.cloud.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "cloud_ssmmessages" {
  vpc_id              = aws_vpc.cloud.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  subnet_ids          = [aws_subnet.cloud_a.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.cloud.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "cloud_s3" {
  vpc_id          = aws_vpc.cloud.id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.cloud.id]
}

resource "aws_instance" "cloudapp" {
  ami                    = data.aws_ami.this.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  subnet_id              = aws_subnet.cloud_a.id
  vpc_security_group_ids = [aws_security_group.cloud.id]
  tags = {
    Name = "cloud-app"
  }
}



