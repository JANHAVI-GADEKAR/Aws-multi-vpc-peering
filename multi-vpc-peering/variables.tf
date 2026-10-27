variable "project_name" {
  type    = string
  default = "multi-vpc-peering"
}

variable "mumbai_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "virginia_vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "canada_vpc_cidr" {
  default = "10.2.0.0/16"
}

variable "mumbai_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "virginia_subnet_cidr" {
  default = "10.1.1.0/24"
}

variable "canada_subnet_cidr" {
  default = "10.2.1.0/24"
}