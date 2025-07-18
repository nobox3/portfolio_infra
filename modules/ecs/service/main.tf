data "aws_region" "current" {}

# ----------------------------------------
# Task definition
# ----------------------------------------
resource "aws_ecs_task_definition" "this" {
  family = var.app_id

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  memory = 512
  cpu    = 256

  container_definitions = jsonencode([
    {
      name         = "nginx"
      image        = var.images.nginx
      portMappings = [{ containerPort = 80, protocol = "tcp" }]
      environment  = []
      secrets      = []
      dependsOn    = [{ containerName = "web", condition = "START" }]
      mountPoints  = [{ containerPath = "/var/run/sockets", sourceVolume = "sockets" }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_names.nginx
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name         = "web"
      image        = var.images.web
      portMappings = []
      environment  = []
      secrets      = []
      mountPoints  = [{ containerPath = "/rails/tmp/sockets", sourceVolume = "sockets" }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_names.web
          awslogs-region        = data.aws_region.current.id
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
  cluster         = var.cluster_arn
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
    security_groups  = var.security_groups
    subnets          = var.subnets
  }

  tags = {
    Name = var.app_id
  }
}
