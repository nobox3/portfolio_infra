terraform {
  cloud {
    organization = "noboru_inoue"

    workspaces {
      name = "social_post-production-ecs"
    }
  }
}

module "config" {
  source = "../../../../../modules/config"

  workspace = "social_post-production-ecs"
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

module "ecs" {
  source = "../../../../../modules/ecs"

  desired_count      = 0
  zone_id            = data.tfe_outputs.host.values.route53_zone_id
  deployer_role_id   = data.tfe_outputs.github_actions.values.deployer_role_id
  app_id             = data.tfe_outputs.app.values.app_id
  ssm_parameter_path = data.tfe_outputs.app.values.ssm_parameter_path
  vpc_id             = data.tfe_outputs.app.values.vpc_id
  target_group_arn   = data.tfe_outputs.app.values.target_group_arn
  app_bucket_id      = data.tfe_outputs.app.values.app_bucket_id
  cdn_id             = data.tfe_outputs.app.values.cdn_id
}
