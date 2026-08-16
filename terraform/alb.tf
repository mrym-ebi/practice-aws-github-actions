# ALB
resource "aws_lb" "main" {
  name               = "${var.project}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [
    aws_subnet.public_1c.id,
    aws_subnet.public_1d.id
  ]

  tags = {
    Name = "${var.project}-${var.env}-alb"
  }
}

# ターゲットグループ
resource "aws_lb_target_group" "main" {
  name        = "${var.project}-${var.env}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"  # Fargateはipタイプが必要

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "${var.project}-${var.env}-tg"
  }
}

# ALBリスナー（HTTPS:443）
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.main.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# ACM証明書（既存のものをdataで参照）
data "aws_acm_certificate" "main" {
  domain   = "everbeacon.net"
  statuses = ["ISSUED"]
}