data "aws_route53_zone" "host" {
  zone_id = var.zone_id
}

resource "aws_route53_record" "root_a" {
  count = var.enable_alb ? 1 : 0

  name    = data.aws_route53_zone.host.name
  type    = "A"
  zone_id = data.aws_route53_zone.host.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_lb.this[0].dns_name
    zone_id                = aws_lb.this[0].zone_id
  }
}

resource "aws_lb" "this" {
  count = var.enable_alb ? 1 : 0

  name = var.app_id

  internal           = false
  load_balancer_type = "application"

  access_logs {
    bucket  = module.log_bucket.s3_bucket_id
    enabled = true
    prefix  = "web"
  }

  security_groups = var.security_groups
  subnets         = var.subnets

  tags = {
    Name = "${var.app_id}-lb"
  }
}

resource "aws_lb_listener" "https" {
  count = var.enable_alb ? 1 : 0

  certificate_arn   = var.certificate_arn
  load_balancer_arn = aws_lb.this[0].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_listener" "redirect_http_to_https" {
  count = var.enable_alb ? 1 : 0

  load_balancer_arn = aws_lb.this[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "this" {
  name = var.app_id

  deregistration_delay = 60
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 30
    matcher             = 200
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.app_id}-lb-target-group"
  }
}
