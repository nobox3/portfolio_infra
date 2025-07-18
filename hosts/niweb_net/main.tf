terraform {
  cloud {
    organization = "noboru_inoue"

    workspaces {
      name = "host_niweb_net"
    }
  }
}

module "config" {
  source = "../../modules/config"

  workspace = "host_niweb_net"
}

module "routing" {
  source = "../../modules/routing/app"

  name = "niweb.net"
}
