  region = var.region
}

locals {
  ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
}

module "networking" {
  source = "../../modules/networking"

  vpc_cidr           = "10.1.0.0/16" # Different CIDR for Prod
  vpc_name           = "prod-vpc"
  public_subnets     = { "a" = "10.1.1.0/24", "b" = "10.1.2.0/24" }
  private_subnets    = { "a" = "10.1.3.0/24", "b" = "10.1.4.0/24" }
  availability_zones = ["${var.region}a", "${var.region}b"]
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "security" {
  source = "../../modules/security"

  vpc_id = module.networking.vpc_id
}

module "eks_cluster" {
  source = "../../modules/eks"

  cluster_name   = "prod-awx-cluster"
  vpc_id         = module.networking.vpc_id
  subnet_ids     = module.networking.private_subnet_ids
  instance_types = ["t3.large"] # Larger instances for Prod
}

module "liberty_server" {
  source = "../../modules/compute"

  name               = "prod-liberty-server"
  ami_id             = local.ami_id
  instance_type      = "t3.medium" # Larger app server
  subnet_id          = module.networking.private_subnet_ids[0]
  security_group_ids = [module.security.liberty_sg_id]
  key_name           = var.key_name
}

module "load_balancer" {
  source = "../../modules/loadbalancer"

  name            = "prod-liberty-alb"
  vpc_id          = module.networking.vpc_id
  subnets         = module.networking.public_subnet_ids
  security_groups = [module.security.liberty_sg_id]
}

module "monitoring_server" {
  source = "../../modules/compute"

  name               = "prod-monitoring-server"
  ami_id             = local.ami_id
  instance_type      = "t3.medium"
  subnet_id          = module.networking.public_subnet_ids[0]
  security_group_ids = [module.security.monitoring_sg_id]
  key_name           = var.key_name
}

resource "aws_lb_target_group_attachment" "liberty" {
  target_group_arn = module.load_balancer.target_group_arn
  target_id        = module.liberty_server.instance_id
  port             = 9080
}

output "eks_cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "liberty_app_url" {
  value = "http://${module.load_balancer.alb_dns_name}"
}

output "monitoring_server_ip" {
  value = module.monitoring_server.public_ip
}
