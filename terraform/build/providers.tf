terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    hcp = {
      source = "hashicorp/hcp"
      version = "0.99.0"
    }
  }

  cloud {
    organization = "swhashi"
    workspaces {
      name = "autobahn-demo-main"
    }
  }
}

provider "aws" {
  region     = var.aws_region
}