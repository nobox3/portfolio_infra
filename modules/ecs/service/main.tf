# ----------------------------------------
# CloudWatch Log Groups
# ----------------------------------------
locals {
  log_group_name_prefix = "/ecs/${var.app_id}"
  log_retention_in_days = 90
}

resource "aws_cloudwatch_log_group" "nginx" {
  name              = "${local.log_group_name_prefix}/nginx"
  retention_in_days = local.log_retention_in_days
}

resource "aws_cloudwatch_log_group" "web" {
  name              = "${local.log_group_name_prefix}/web"
  retention_in_days = local.log_retention_in_days
}

# ----------------------------------------
# Task definition
# ----------------------------------------
resource "aws_ecs_task_definition" "this" {
  family = var.app_id

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = data.aws_iam_role.ecs_task_execution.arn
  task_role_arn            = data.aws_iam_role.ecs_task.arn

  memory = 512
  cpu    = 256

  container_definitions = jsonencode([
    {
      name         = "nginx"
      image        = data.aws_ecr_image.nginx.image_uri
      portMappings = [{ containerPort = 80, protocol = "tcp" }]
      environment  = []
      secrets      = []
      dependsOn    = [{ containerName = "web", condition = "START" }]
      mountPoints  = [{ containerPath = "/var/run/sockets", sourceVolume = "sockets" }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.nginx.name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name         = "web"
      image        = data.aws_ecr_image.web.image_uri
      portMappings = []
      environment  = []
      secrets      = []
      mountPoints  = [{ containerPath = "/rails/tmp/sockets", sourceVolume = "sockets" }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.web.name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  volume {
    name = "sockets"
  }

  tags = {
    Name = var.app_id
  }
}

# ----------------------------------------
# ECS Service
# ----------------------------------------
resource "aws_ecs_service" "this" {
  name            = var.app_id
  cluster         = data.aws_ecs_cluster.app.arn
  task_definition = aws_ecs_task_definition.this.arn

  desired_count                      = var.desired_count
  enable_execute_command             = true
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60

  platform_version = "1.4.0"

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 1
  }

  load_balancer {
    container_name   = "nginx"
    container_port   = 80
    target_group_arn = var.target_group_arn
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = data.aws_security_groups.app.ids
    subnets          = data.aws_subnets.app.ids
  }

  tags = {
    Name = var.app_id
  }
}
