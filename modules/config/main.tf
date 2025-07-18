terraform {
  required_providers {
    tfe = {
      version = "~> 0.67.1"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2.0"
    }
  }

  required_version = "1.12.2"
}

provider "tfe" {
  organization = var.organization
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.project
      Workspace = var.workspace
    }
  }
}
