# EC2

resource "aws_instance" "jenkins_ec2" {
  ami                         = aws_launch_template.jenkins_launch_template.image_id
  instance_type               = var.instance_type
  # key_name                    = "new-ec2-key"
  monitoring                  = true
  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.150" # Set your desired max price here
      spot_instance_type = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }
  vpc_security_group_ids      = [module.sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("../scripts/install_build_tools.sh")
  availability_zone           = data.aws_availability_zones.azs.names[0]

  tags = {
    Name        = var.jenkins_ec2_instance
    cost        = var.jenkins_ec2_instance
    Terraform   = "true"
    Environment = "dev"
  }
}

/*
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.8.0"

  name = var.jenkins_ec2_instance

  instance_type               = var.instance_type
  ami                         = "ami-0daee08993156ca1a"
  key_name                    = "new-ec2-key"
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("../scripts/install_build_tools.sh")
  availability_zone           = data.aws_availability_zones.azs.names[0]

  tags = {
    Name        = "jenkins"
    Terraform   = "true"
    Environment = "dev"
    cost        = "eks-dev-jenkins-server"
  }
}
*/

/*
resource "aws_spot_instance_request" "jenkins_spot_instance" {
  instance_interruption_behavior = "terminate"
  instance_type                  = var.instance_type
  ami                            = "ami-0daee08993156ca1a"
  key_name                       = "new-ec2-key"
  subnet_id                      = module.vpc.public_subnets[0]
  security_groups                = [module.sg.security_group_id]
  associate_public_ip_address = true
  user_data                      = file("../scripts/install_build_tools.sh")
  availability_zone           = data.aws_availability_zones.azs.names[0]

  # t3a.large t3a.medium
  # 0.0336    0.0150
  spot_price                     = "0.150" # Set your desired max price here
  wait_for_fulfillment           = true

  tags = {
    Name        = var.jenkins_ec2_instance
    Terraform   = "true"
    Environment = "dev"
    cost        = "eks-dev-jenkins-server-spot"
  }
}
*/