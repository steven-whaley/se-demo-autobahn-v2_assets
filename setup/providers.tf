terraform {
  required_providers {
    tfe = {
      version = "~> 0.59.0"
    }
    aws = {
      version = "5.76.0"
    }
  }
}

provider "tfe" {
  token        = var.tfe_token
  organization = var.tfe_organization_name
}

provider "hcp" {
  client_id = var.hcp_client_id
  client_secret = var.hcp_client_secret
}

provider "aws" {
  region = var.aws_region
}

