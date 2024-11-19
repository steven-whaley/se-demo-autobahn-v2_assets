# AWS
variable "aws_region" {
  type = string
  default = "us-west-2"
}

# HCP
variable "hcp_client_id" {
  type = string
}

variable hcp_client_secret {
  type = string
}

# TF
variable "tfe_org" {
  type=string
}