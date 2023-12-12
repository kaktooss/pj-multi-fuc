resource "aws_lb" "router" {
  name               = "${var.environment}-router"
  load_balancer_type = "network"
  internal           = false
  subnets            = module.vpc.public_subnets
}

resource "aws_security_group" "wireguard_ssh_check" {
  name   = "${var.environment}-router-check"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }
}

resource "aws_lb_target_group" "router" {
  name_prefix = "rt-"
  port        = 53145
  protocol    = "UDP"
  vpc_id      = module.vpc.vpc_id

  health_check {
    port     = 22
    protocol = "TCP"
  }
  tags = {
    Name = "${var.environment}-router"
  }
}

resource "aws_lb_listener" "router" {
  load_balancer_arn = aws_lb.router.arn
  port              = 53145
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.router.arn
  }
}

resource "aws_lb_target_group_attachment" "router" {
  target_group_arn = aws_lb_target_group.router.arn
  target_id        = aws_instance.router.id
  port             = 53145
}

resource "aws_route53_record" "router" {
  name = "router.${var.public_domain}"
  type = "A"
  alias {
    evaluate_target_health = false
    name                   = aws_lb.router.dns_name
    zone_id                = aws_lb.router.zone_id
  }
  zone_id = var.public_zone_id
}