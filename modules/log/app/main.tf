locals {
  name_prefix = "/ecs/${var.app_id}"
}

resource "aws_cloudwatch_log_group" "nginx" {
  name = "${local.name_prefix}/nginx"

  retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_log_group" "web" {
  name = "${local.name_prefix}/web"

  retention_in_days = var.retention_in_days
}
