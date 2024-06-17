variable "cloud_vpc_cidr" {
  type = string
  description = "CIDR range for cloud vpc"
}

variable "onprem_vpc_cidr" {
  type = string
  description = "CIDR range for onprem network"
}

variable "onprem_subnet_cidr" {
  type = string
  description = "CIDR range for onprem network"
}

variable "cloud_subnet_cidr_a" {
  type = string
  description = "CIDR range for first cloud subnet"
}

variable "cloud_subnet_cidr_b" {
  type = string
  description = "CIDR range for second cloud subnet"
}


variable "region" {
    type = string
    description = "Region used for deployment"
}