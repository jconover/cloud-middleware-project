variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance (e.g., Amazon Linux 2 or Ubuntu). Leave empty to use latest Ubuntu 22.04"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "SSH Key Pair name"
  type        = string
}
