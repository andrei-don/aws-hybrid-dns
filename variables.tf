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

variable "region" {
    type = string
    description = "Region used for deployment"
}