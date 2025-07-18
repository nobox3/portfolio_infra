terraform {
  cloud {
    organization = "noboru_inoue"

    workspaces {
      name = "github_actions"
    }
  }
}

module "config" {
  source = "../modules/config"

  workspace = "github_actions"
}

locals {
  name = "${module.config.this.project}-${module.config.this.workspace}"
}

resource "aws_iam_user" "github_actions" {
  name = local.name

  tags = {
    Name = local.name
  }
}

# ----------------------------------------
# Role and policy
# ----------------------------------------
resource "aws_iam_role" "deployer" {
  name               = "${local.name}-deployer"
  assume_role_policy = data.aws_iam_policy_document.deployer.json

  tags = {
    Name = "${local.name}-deployer"
  }
}

resource "aws_iam_role_policy_attachment" "role_deployer_policy_ecr_power_user" {
  role       = aws_iam_role.deployer.name
  policy_arn = data.aws_iam_policy.ecr_power_user.arn
}

data "aws_iam_policy_document" "deployer" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.github_actions.arn]
    }
  }
}

data "aws_iam_policy" "ecr_power_user" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
