resource "aws_lb" "web_alb" {
  name               = "web-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id
  depends_on = [ aws_internet_gateway.igw ]
  tags = {
    Name = "web-app-alb"
  }
}

resource "aws_lb_target_group" "webapp_tg" {
  name     = "webapp-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_custom_vpc.id

  health_check {
    path                = "/hello"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher = "200"
    port = 8080
  }
    tags = {
        Name = "web-app-tg"
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"
  
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
  tags = {
    Name = "web-app-alb-listener"
  }
}

