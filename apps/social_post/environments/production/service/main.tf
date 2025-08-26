terraform {
  cloud {
    organization = "noboru_inoue"

    workspaces {
      name = "social_post-production-service"
    }
  }
}

module "config" {
  source = "../../../../../modules/config"

  workspace = "social_post-production-service"
}

data "tfe_outputs" "host" {
  organization = module.config.this.organization
  workspace    = "host_niweb_net"
}

data "tfe_outputs" "github_actions" {
  organization = module.config.this.organization
  workspace    = "github_actions"
}

data "tfe_outputs" "app" {
  organization = module.config.this.organization
  workspace    = "social_post-production"
}

module "service" {
  source = "../../../../../modules/ecs/service"

  desired_count    = 0
  app_id           = data.tfe_outputs.app.values.app_id
  vpc_id           = data.tfe_outputs.app.values.vpc_id
  target_group_arn = data.tfe_outputs.app.values.target_group_arn
  deployer_role_id = data.tfe_outputs.github_actions.values.deployer_role_id
}
