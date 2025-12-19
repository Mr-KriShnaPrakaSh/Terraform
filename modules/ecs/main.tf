# ECS clusters with Fargate and Container Insights
resource "aws_ecs_cluster" "pp" {
  name = "${var.env_name}-pp-cluster"

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }
}

resource "aws_ecs_cluster" "dd" {
  name = "${var.env_name}-dd-cluster"

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }
}

locals {
  services = {
    "pp-api"       = { cluster = aws_ecs_cluster.pp.id, container_port = 5000, tg_arn = var.pp_target_groups["api"] }
    "pp-realtime"  = { cluster = aws_ecs_cluster.pp.id, container_port = 5001, tg_arn = var.pp_target_groups["realtime"] }
    "pp-analytics" = { cluster = aws_ecs_cluster.pp.id, container_port = 5002, tg_arn = var.pp_target_groups["analytics"] }

    "dd-api"       = { cluster = aws_ecs_cluster.dd.id, container_port = 5000, tg_arn = var.dd_target_groups["api"] }
    "dd-realtime"  = { cluster = aws_ecs_cluster.dd.id, container_port = 5001, tg_arn = var.dd_target_groups["realtime"] }
    "dd-analytics" = { cluster = aws_ecs_cluster.dd.id, container_port = 5002, tg_arn = var.dd_target_groups["analytics"] }
  }
}

data "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskExecRoles"
}

data "aws_iam_role" "ecs_execution_role" {
  name = "ecsTaskExecutionRole" 
}

# ----------------------
# ECS Task Definitions
# ----------------------
resource "aws_ecs_task_definition" "task" {
  for_each                 = local.services
  family                    = "${var.env_name}-${each.key}"
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = var.cpu
  memory                    = var.memory
  execution_role_arn        = data.aws_iam_role.ecs_execution_role.arn
  task_role_arn             = data.aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = each.key
      image = "public.ecr.aws/docker/library/nginx:latest" # CI/CD will update
      essential = true
      portMappings = [{
        containerPort = each.value.container_port
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${each.key}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# ----------------------
# ECS Services
# ----------------------
resource "aws_ecs_service" "service" {
  for_each           = local.services
  name               = "${var.env_name}-${each.key}-service"
  cluster            = each.value.cluster
  task_definition    = aws_ecs_task_definition.task[each.key].arn
  desired_count      = 1
  launch_type        = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet
    security_groups  = [var.app_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = each.value.tg_arn
    container_name   = each.key
    container_port   = each.value.container_port
  }

  depends_on = [var.listeners_https]
}
