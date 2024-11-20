terraform {
  required_providers {
    tfe = {
      version = "~> 0.59.0"
    }
    aws = {
      version = "5.76.0"
    }
    hcp = {
      source = "hashicorp/hcp"
      version = "0.99.0"
    }
    terraform = {
      source = "terraform.io/builtin/terraform"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "tfe" {
  organization = var.tfe_org
}

provider "hcp" {
  client_id = var.hcp_client_id
  client_secret = var.hcp_client_secret
}
