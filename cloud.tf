resource "aws_vpc" "cloud" {
  cidr_block = var.cloud_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "cloud_vpc"
  }
}


