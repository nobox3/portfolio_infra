# ----------------------------------------
# Task execution
# ----------------------------------------
resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.app_id}-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution.json

  tags = {
    Name = "${var.app_id}-ecs-task-execution"
  }
}

data "aws_iam_policy_document" "ecs_task_execution" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = data.aws_iam_policy.ecs_task_execution.arn
}

data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ----------------------------------------
# SSM
# ----------------------------------------
resource "aws_iam_policy" "ssm" {
  name   = "${var.app_id}-ssm"
  policy = data.aws_iam_policy_document.ssm.json

  tags = {
    Name = "${var.app_id}-ssm"
  }
}

data "aws_iam_policy_document" "ssm" {
  statement {
    actions = ["ssm:GetParameters", "ssm:GetParameter"]

    resources = [
      "arn:aws:ssm:${local.arn_self}:parameter${var.ssm_parameter_path}/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_ssm" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ssm.arn
}

