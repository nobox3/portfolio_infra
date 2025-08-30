locals {
  arn_self = "${data.aws_region.current.region}:${data.aws_caller_identity.self.account_id}"
}

resource "aws_iam_role_policy" "ecs_deploy" {
  name   = "ecs-deploy"
  role   = var.deployer_role_id
  policy = data.aws_iam_policy_document.ecs_deploy.json
}

data "aws_iam_policy_document" "ecs_deploy" {
  statement {
    sid = "RegisterTaskDefinition"

    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:ListTaskDefinitions",
      "ecs:DescribeTaskDefinition",
      "ecs:TagResource"
    ]

    resources = ["*"]
  }

  statement {
    sid       = "PassRolesInTaskDefinition"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.ecs_task_execution.arn, aws_iam_role.ecs_task.arn]
  }

  statement {
    sid       = "DeployService"
    actions   = ["ecs:UpdateService", "ecs:DescribeServices"]
    resources = [aws_ecs_service.this.arn]
  }

  statement {
    sid     = "RunAndWaitTask"
    actions = ["ecs:RunTask", "ecs:DescribeTasks"]

    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = [aws_ecs_cluster.this.arn]
    }

    resources = [
      "arn:aws:ecs:${local.arn_self}:task-definition/${var.app_id}:*",
      "arn:aws:ecs:${local.arn_self}:task/*"
    ]
  }

  statement {
    sid       = "GetLogEvents"
    actions   = ["logs:GetLogEvents"]
    resources = [aws_cloudwatch_log_group.web.arn, aws_cloudwatch_log_group.nginx.arn]
  }
}
