terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    doormat = {
      source = "doormat.hashicorp.services/hashicorp-security/doormat"
      version = "~> 0.0.11"
    }
  }

  cloud {
    organization = "swhashi"
    workspaces {
      name = "autobahn-demo-main"
    }
  }
}

provider "doormat" {}

provider "aws" {
  access_key = data.doormat_aws_credentials.creds.access_key
  secret_key = data.doormat_aws_credentials.creds.secret_key
  token      = data.doormat_aws_credentials.creds.token
  region     = var.aws_region
}

provider "hcp" {
  client_id = var.hcp_client_id
  client_secret = var.hcp_client_secret
}