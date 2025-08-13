# We'll be using publicly available modules for creating different services instead of resources
# https://registry.terraform.io/browse/modules?provider=aws

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs            = data.aws_availability_zones.azs.names  
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets

  enable_dns_hostnames = true
  single_nat_gateway = true
  enable_nat_gateway = true  # enable_private_nat_gateway_route = true
  one_nat_gateway_per_az = false

  tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"

    Terraform   = "true"
    Environment = "dev"
    cost = var.eks_cluster_name
  }

  nat_gateway_tags = {
    Name = "${var.eks_cluster_name}-nat"
    cost = "${var.eks_cluster_name}-nat"
  }

  public_subnet_tags = {    
    Name = "${var.eks_cluster_name}-public-subnet"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    Name = "${var.eks_cluster_name}-private-subnet"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}  


// alb 등록
/*
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.17.0"

  vpc_id = module.vpc.vpc_id
  name = "${var.eks_cluster_name}-alb"
  subnets = module.vpc.public_subnets

  tags = {
    cost = "${var.eks_cluster_name}-alb"
  }
}

resource "aws_lb_target_group" "app" {
  name     = "${var.eks_cluster_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  target_type = "ip" # EKS Pod를 직접 연결할 경우 "ip"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.alb.this_lb_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
*/