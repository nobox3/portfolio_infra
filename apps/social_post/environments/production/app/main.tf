terraform {
  cloud {
    organization = "noboru_inoue"

    workspaces {
      name = "social_post-production"
    }
  }
}

module "config" {
  source = "../../../../../modules/config"

  workspace = "social_post-production"
}

data "tfe_outputs" "host" {
  organization = module.config.this.organization
  workspace    = "host_niweb_net"
}

data "tfe_outputs" "github_actions" {
  organization = module.config.this.organization
  workspace    = "github_actions"
}

data "tfe_outputs" "repository" {
  organization = module.config.this.organization
  workspace    = "${module.config.this.workspace}-repository"
}

locals {
  app_id = "${module.config.this.project}-${module.config.this.workspace}"
}

module "app" {
  source = "../../../modules/app"

  organization           = module.config.this.organization
  workspace              = module.config.this.workspace
  app_id                 = local.app_id
  host_zone_id           = data.tfe_outputs.host.values.route53_zone_id
  deployer_role_id       = data.tfe_outputs.github_actions.values.deployer_role_id
  repository_name_prefix = data.tfe_outputs.repository.values.name_prefix

  enable_alb         = false
  enable_nat_gateway = false
}
