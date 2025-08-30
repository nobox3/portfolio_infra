resource "aws_iam_role" "ecs_task" {
  name               = "${var.app_id}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task.json

  tags = {
    Name = "${var.app_id}-ecs-task"
  }
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ----------------------------------------
# S3
# ----------------------------------------
resource "aws_iam_role_policy" "ecs_task_app_bucket" {
  name   = "app-bucket"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_task_app_bucket.json
}

data "aws_iam_policy_document" "ecs_task_app_bucket" {
  statement {
    actions   = ["s3:ListBucket", "s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
    resources = [data.aws_s3_bucket.app.arn, "${data.aws_s3_bucket.app.arn}/*"]
  }
}

# ----------------------------------------
# SSM
# ----------------------------------------
resource "aws_iam_role_policy" "ecs_task_ssm" {
  name   = "ssm"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_task_ssm.json
}

data "aws_iam_policy_document" "ecs_task_ssm" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]
  }
}
