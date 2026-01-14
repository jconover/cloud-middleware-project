provider "aws" {
  region = var.region
}

module "networking" {
  source = "../../modules/networking"

  vpc_cidr           = "10.0.0.0/16"
  vpc_name           = "dev-vpc"
  public_subnets     = { "a" = "10.0.1.0/24", "b" = "10.0.2.0/24" }
  private_subnets    = { "a" = "10.0.3.0/24", "b" = "10.0.4.0/24" }
  availability_zones = ["${var.region}a", "${var.region}b"]
}

module "security" {
  source = "../../modules/security"

  vpc_id = module.networking.vpc_id
}

module "eks_cluster" {
  source = "../../modules/eks"

  cluster_name   = "dev-awx-cluster"
  vpc_id         = module.networking.vpc_id
  subnet_ids     = module.networking.private_subnet_ids # EKS nodes in private subnets
  instance_types = ["t3.medium"]
}

module "liberty_server" {
  source = "../../modules/compute"

  name               = "dev-liberty-server"
  ami_id             = var.ami_id
  instance_type      = "t3.small"
  subnet_id          = module.networking.private_subnet_ids[0] # App in private subnet
  security_group_ids = [module.security.liberty_sg_id]
  key_name           = var.key_name
}

module "load_balancer" {
  source = "../../modules/loadbalancer"

  name            = "dev-liberty-alb"
  vpc_id          = module.networking.vpc_id
  subnets         = module.networking.public_subnet_ids # LB in public subnets
  security_groups = [module.security.liberty_sg_id] # Should technically have its own LB SG, reusing for simplicty or create new
}

module "monitoring_server" {
  source = "../../modules/compute"

  name               = "dev-monitoring-server"
  ami_id             = var.ami_id
  instance_type      = "t3.small"
  subnet_id          = module.networking.public_subnet_ids[0] # Public for access to Grafana
  security_group_ids = [module.security.monitoring_sg_id]
  key_name           = var.key_name
}

# Attach Liberty Server to Target Group
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
