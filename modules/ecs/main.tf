# ----------------------------------------
# ECS Cluster
# ----------------------------------------
resource "aws_ecs_cluster" "this" {
  name = var.app_id

  tags = {
    Name = var.app_id
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

# ----------------------------------------
# ECS Service
# ----------------------------------------
resource "aws_ecs_service" "this" {
  name            = var.app_id
  cluster         = aws_ecs_cluster.this.arn
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
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  memory = 512
  cpu    = 256

  container_definitions = jsonencode([
    {
      name         = "nginx"
      image        = data.aws_ecr_image.nginx.image_uri
      portMappings = [{ containerPort = 80, protocol = "tcp" }]
      environment = [
        {
          name  = "APP_HOST"
          value = data.aws_route53_zone.host.name
        },
        {
          name  = "VPC_CIDR"
          value = data.aws_vpc.app.cidr_block
        }
      ]
      secrets     = []
      dependsOn   = [{ containerName = "web", condition = "START" }]
      mountPoints = [{ containerPath = "/var/run/sockets", sourceVolume = "sockets" }]

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
      environment = [
        {
          name  = "APP_HOST"
          value = data.aws_route53_zone.host.name
        },
        {
          name  = "AWS_REGION"
          value = data.aws_region.current.region
        },
        {
          name  = "DATABASE_HOST"
          value = data.aws_db_instance.app.address
        },
        {
          name  = "REDIS_URL"
          value = "rediss://${data.aws_elasticache_replication_group.app.primary_endpoint_address}/1"
        },
        {
          name  = "AWS_S3_BUCKET"
          value = var.app_bucket_id
        },
        {
          name  = "CDN_HOST"
          value = data.aws_cloudfront_distribution.app.domain_name
        },
      ]
      secrets = [
        {
          name      = "SECRET_KEY_BASE"
          valueFrom = "${var.ssm_parameter_path}/SECRET_KEY_BASE"
        },
        {
          name      = "DATABASE_NAME"
          valueFrom = "${var.ssm_parameter_path}/DATABASE_NAME"
        },
        {
          name      = "DATABASE_USERNAME"
          valueFrom = "${var.ssm_parameter_path}/DATABASE_USERNAME"
        },
        {
          name      = "DATABASE_PASSWORD"
          valueFrom = "${var.ssm_parameter_path}/DATABASE_PASSWORD"
        },
        {
          name      = "STORAGE_SERVICE"
          valueFrom = "${var.ssm_parameter_path}/STORAGE_SERVICE"
        },
        {
          name      = "ENABLE_BASIC_AUTH"
          valueFrom = "${var.ssm_parameter_path}/ENABLE_BASIC_AUTH"
        },
        {
          name      = "BASIC_AUTH_USERNAME"
          valueFrom = "${var.ssm_parameter_path}/BASIC_AUTH_USERNAME"
        },
        {
          name      = "BASIC_AUTH_PASSWORD"
          valueFrom = "${var.ssm_parameter_path}/BASIC_AUTH_PASSWORD"
        },
        {
          name      = "GOOGLE_OAUTH_CLIENT_ID"
          valueFrom = "${var.ssm_parameter_path}/GOOGLE_OAUTH_CLIENT_ID"
        },
        {
          name      = "GOOGLE_OAUTH_CLIENT_SECRET"
          valueFrom = "${var.ssm_parameter_path}/GOOGLE_OAUTH_CLIENT_SECRET"
        },
        {
          name      = "SENDGRID_API_KEY"
          valueFrom = "${var.ssm_parameter_path}/SENDGRID_API_KEY"
        },
        {
          name      = "SENDGRID_SUBSCRIPTION_WEBHOOK_VERIFICATION_KEY"
          valueFrom = "${var.ssm_parameter_path}/SENDGRID_SUBSCRIPTION_WEBHOOK_VERIFICATION_KEY"
        }
      ]
      mountPoints = [{ containerPath = "/rails/tmp/sockets", sourceVolume = "sockets" }]

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
