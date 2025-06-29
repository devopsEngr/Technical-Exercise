terraform {
  backend "s3" {
    bucket         = "springboot-terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = "terraform-locks"   
    encrypt        = true
  }
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_launch_template" "lt" {
  name_prefix   = "web-app-"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2_sg.id]
  }

user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    aws_region     = var.aws_region,
    aws_account_id = var.aws_account_id,
    image_version  = var.image_version
  }))
  depends_on = [aws_iam_instance_profile.ec2_instance_profile]
  lifecycle {
  create_before_destroy = true
}

}
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity     = 1
  max_size             = 2
  min_size             = 1
  vpc_zone_identifier  = aws_subnet.private_subnet[*].id
  target_group_arns =  [aws_lb_target_group.webapp_tg.arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "web-app-asg"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}
  
