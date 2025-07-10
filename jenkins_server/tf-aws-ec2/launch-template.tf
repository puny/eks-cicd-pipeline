
resource "aws_launch_template" "jenkins_launch_template" {
  name_prefix   = "spot-jenkins-launch-template-"
  image_id      = "ami-03e38f46f79020a70"
  instance_type = var.instance_type
  key_name      = var.key_name
#   user_data     = file("../scripts/install_build_tools.sh")

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 10
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [module.sg.security_group_id]
  }

  tags = {
    Name = "jenkins-spot-instance-launch-template"
  }
}