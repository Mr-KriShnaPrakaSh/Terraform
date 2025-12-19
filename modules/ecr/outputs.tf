output "api_ecr_url" { value = aws_ecr_repository.api.repository_url }
output "realtime_ecr_url" { value = aws_ecr_repository.realtime.repository_url }
output "ecs_execution_role_arn" { value = aws_iam_role.ecs_task_execution_role.arn }

