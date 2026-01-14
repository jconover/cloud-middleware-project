variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "Map of public subnets with CIDR blocks"
  type        = map(string)
}

variable "private_subnets" {
  description = "Map of private subnets with CIDR blocks"
  type        = map(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets (costs money)"
  type        = bool
  default     = false
}
