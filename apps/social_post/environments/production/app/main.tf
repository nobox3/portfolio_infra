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

locals {
  app_id = "${module.config.this.project}-${module.config.this.workspace}"
}

module "app" {
  source = "../../../modules/app"

  organization    = module.config.this.organization
  workspace       = module.config.this.workspace
  app_id          = local.app_id
  host_zone_id    = data.tfe_outputs.host.values.route53_zone_id
  certificate_arn = data.tfe_outputs.host.values.acm_certificate_root_arn

  enable_alb         = false
  enable_nat_gateway = false
}
