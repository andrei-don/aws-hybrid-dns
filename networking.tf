resource "aws_vpc" "cloud" {
  cidr_block           = var.cloud_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "cloud_vpc"
  }
}

resource "aws_subnet" "cloud_a" {
  vpc_id            = aws_vpc.cloud.id
  cidr_block        = var.cloud_subnet_cidr_a
  availability_zone = "${var.region}a"
  tags = {
    Name = "cloud_subnet_a"
  }
}

resource "aws_subnet" "cloud_b" {
  vpc_id            = aws_vpc.cloud.id
  cidr_block        = var.cloud_subnet_cidr_b
  availability_zone = "${var.region}b"
  tags = {
    Name = "cloud_subnet_b"
  }
}

resource "aws_route_table" "cloud" {
  vpc_id = aws_vpc.cloud.id

  tags = {
    Name = "cloud_rt"
  }
}

resource "aws_route_table_association" "cloud_a" {
  subnet_id      = aws_subnet.cloud_a.id
  route_table_id = aws_route_table.cloud.id
}

resource "aws_route_table_association" "cloud_b" {
  subnet_id      = aws_subnet.cloud_b.id
  route_table_id = aws_route_table.cloud.id
}

resource "aws_vpc" "onprem" {
  cidr_block           = var.onprem_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "onprem_vpc"
  }
}

resource "aws_subnet" "onprem" {
  vpc_id     = aws_vpc.onprem.id
  cidr_block = var.onprem_subnet_cidr
  tags = {
    Name = "onprem_subnet"
  }
}

resource "aws_route_table" "onprem" {
  vpc_id = aws_vpc.onprem.id

  tags = {
    Name = "onprem_rt"
  }
}

resource "aws_route_table_association" "onprem" {
  subnet_id      = aws_subnet.onprem.id
  route_table_id = aws_route_table.onprem.id
}

resource "aws_vpc_peering_connection" "this" {
  peer_vpc_id = aws_vpc.onprem.id
  vpc_id      = aws_vpc.cloud.id
  auto_accept = true
}

resource "aws_route" "cloud" {
  route_table_id            = aws_route_table.cloud.id
  destination_cidr_block    = var.onprem_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "onprem" {
  route_table_id            = aws_route_table.onprem.id
  destination_cidr_block    = var.cloud_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}