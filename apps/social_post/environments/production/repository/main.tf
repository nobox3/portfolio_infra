terraform {
  cloud {
    organization = "noboru_inoue"

    workspaces {
      name = "social_post-production-repository"
    }
  }
}

module "config" {
  source = "../../../../../modules/config"

  workspace = "social_post-production-repository"
}

locals {
  name_prefix = "${module.config.this.project}-social_post-production"
}

module "nginx" {
  source = "../../../../../modules/ecr"

  name          = "${local.name_prefix}-nginx"
  holding_count = 1
  force_delete  = true
}

module "web" {
  source = "../../../../../modules/ecr"

  name          = "${local.name_prefix}-web"
  holding_count = 1
  force_delete  = true
}
