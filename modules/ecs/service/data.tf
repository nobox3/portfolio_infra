data "aws_caller_identity" "self" {}

data "aws_region" "current" {}

data "aws_ecr_image" "nginx" {
  repository_name = "${var.app_id}-nginx"
  most_recent     = true
}

data "aws_ecr_image" "web" {
  repository_name = "${var.app_id}-web"
  most_recent     = true
}

data "aws_ecs_cluster" "app" {
  cluster_name = var.app_id
}

data "aws_iam_role" "ecs_task" {
  name = "${var.app_id}-ecs-task"
}

data "aws_iam_role" "ecs_task_execution" {
  name = "${var.app_id}-ecs-task-execution"
}

data "aws_vpc" "app" {
  id = var.vpc_id
}

data "aws_security_groups" "app" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name = "group-name"

    values = [
      "${data.aws_vpc.app.tags.Name}-vpc",
      "${data.aws_vpc.app.tags.Name}-db",
      "${data.aws_vpc.app.tags.Name}-cache",
    ]
  }
}

data "aws_subnets" "app" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["${data.aws_vpc.app.tags.Name}-private-*"]
  }
}
