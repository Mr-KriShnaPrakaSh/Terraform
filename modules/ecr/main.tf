# -------------------------------
# ECR Repositories
# -------------------------------
resource "aws_ecr_repository" "api" {
  name = "${var.env_name}-api"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "realtime" {
  name = "${var.env_name}-realtime"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "analytics" {
  name = "${var.env_name}-analytics"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# -------------------------------
# IAM Role for ECS Task Execution
# -------------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.env_name}-ecs-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -------------------------------
# CloudWatch Log Groups
# -------------------------------
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.env_name}-api"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "realtime" {
  name              = "/ecs/${var.env_name}-realtime"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "analytics" {
  name              = "/ecs/${var.env_name}-analytics"
  retention_in_days = 14
}

