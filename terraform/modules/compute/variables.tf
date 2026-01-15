variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be placed"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "key_name" {
  description = "SSH Key Name"
  type        = string
}

variable "name" {
  description = "Name tag for the instance"
  type        = string
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = ""
}
