# AWS
variable "aws_region" {
  type = string
  default = "us-west-2"
}

# TFE
variable "tfe_organization_name" {
  type = string
}

variable "tfe_token" {
  type        = string
  description = "A TFE token"
  default = null
}

# HCP
variable "hcp_organization_name" {
    type = string
}

variable "hcp_client_id" {
  type        = string
  description = "The HCP service principal client ID that will be used to manage HCP Packer things. This should be set up in the HCP console before running this module"
  default = null
}

variable "hcp_client_secret" {
  type        = string
  description = "The HCP service principal key that will be used to manage HCP Packer things. This should be set up in the HCP console before running this module"
  default = null
}