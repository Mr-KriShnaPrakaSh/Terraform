# ----------------------
# Load Balancers
# ----------------------
resource "aws_lb" "pp" {
  name               = "${var.env_name}-pp-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnet
  security_groups    = [var.app_sg_id]
}

resource "aws_lb" "dd" {
  name               = "${var.env_name}-dd-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnet
  security_groups    = [var.app_sg_id]
}

# ----------------------
# Local Ports
# ----------------------
locals {
  ports = {
    api       = 5000
    realtime  = 5001
    analytics = 5002
  }
}

# ----------------------
# Target Groups - PP
# ----------------------
resource "aws_lb_target_group" "pp" {
  for_each    = local.ports
  name        = "${var.env_name}-pp-${each.key}-tg"
  port        = each.value
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol = "HTTP"
    path     = "/health"
    matcher = "200"
  }
}

# ----------------------
# Target Groups - DD
# ----------------------
resource "aws_lb_target_group" "dd" {
  for_each    = local.ports
  name        = "${var.env_name}-dd-${each.key}-tg"
  port        = each.value
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol = "HTTP"
    path     = "/health"
    matcher = "200"
  }
}

# ----------------------
# HTTP Listeners → Redirect to HTTPS
# ----------------------
resource "aws_lb_listener" "pp_http" {
  for_each          = local.ports
  load_balancer_arn = aws_lb.pp.arn
  port              = each.value
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "dd_http" {
  for_each          = local.ports
  load_balancer_arn = aws_lb.dd.arn
  port              = each.value
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# ----------------------
# ACM Certificates
# ----------------------
data "aws_acm_certificate" "pandapower_cert" {
  domain      = "pandapower777.com"
  types       = ["AMAZON_ISSUED"]
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_acm_certificate" "dingdinghouse_cert" {
  domain      = "dingdinghouse.com"
  types       = ["AMAZON_ISSUED"]
  statuses    = ["ISSUED"]
  most_recent = true
}

# ----------------------
# HTTPS Listeners
# ----------------------
resource "aws_lb_listener" "pp_https" {
  load_balancer_arn = aws_lb.pp.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
  certificate_arn   = data.aws_acm_certificate.pandapower_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pp["api"].arn
  }
}

resource "aws_lb_listener" "dd_https" {
  load_balancer_arn = aws_lb.dd.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
  certificate_arn   = data.aws_acm_certificate.dingdinghouse_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dd["api"].arn
  }
}

# ----------------------
# HTTPS Listener Rules - PP
# ----------------------
resource "aws_lb_listener_rule" "pp_rules" {
  for_each     = local.ports
  listener_arn = aws_lb_listener.pp_https.arn
  priority     = 10 + index(keys(local.ports), each.key) * 10

  condition {
    path_pattern {
      values = ["/${each.key}/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pp[each.key].arn
  }
}

# ----------------------
# HTTPS Listener Rules - DD
# ----------------------
resource "aws_lb_listener_rule" "dd_rules" {
  for_each     = local.ports
  listener_arn = aws_lb_listener.dd_https.arn
  priority     = 10 + index(keys(local.ports), each.key) * 10

  condition {
    path_pattern {
      values = ["/${each.key}/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dd[each.key].arn
  }
}
