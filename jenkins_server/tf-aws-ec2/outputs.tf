output "ec2_instance_ip" {
    # value = module.ec2_instance.public_ip
    # value = aws_spot_instance_request.jenkins_spot_instance.public_ip
    value = aws_instance.jenkins_ec2.public_ip
}

