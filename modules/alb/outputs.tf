output "pp_target_groups" {
  value = { for k, tg in aws_lb_target_group.pp : k => tg.arn }
}

output "dd_target_groups" {
  value = { for k, tg in aws_lb_target_group.dd : k => tg.arn }
}

output "pp_alb_arn" { value = aws_lb.pp.arn }
output "dd_alb_arn" { value = aws_lb.dd.arn }

output "pp_https_listener" { value = aws_lb_listener.pp_https.arn }
output "dd_https_listener" { value = aws_lb_listener.dd_https.arn }
