terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.99.0"
    }
  }
}

provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}

