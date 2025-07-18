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

  app_id                  = data.tfe_outputs.app.values.app_id
  task_execution_role_arn = data.tfe_outputs.app.values.task_execution_role_arn
  task_role_arn           = data.tfe_outputs.app.values.task_role_arn
  images                  = data.tfe_outputs.app.values.images
  log_group_names         = data.tfe_outputs.app.values.log_group_names

  desired_count    = 0
  cluster_arn      = data.tfe_outputs.app.values.cluster_arn
  security_groups  = data.tfe_outputs.app.values.security_groups
  subnets          = data.tfe_outputs.app.values.subnets
  target_group_arn = data.tfe_outputs.app.values.target_group_arn
  deployer_role_id = data.tfe_outputs.github_actions.values.deployer_role_id
}
