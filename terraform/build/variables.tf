variable "packer_version" {
    type = string
    description = "The version to set on our packer build.  Changing this will trigger a rebuild of the image"
}

variable "demo_prefix" {
  type = string
  description = "Set this to a short (XXX HOW SHORT?) string, which will be prepended to resources this creates"
}

### AWS ###

variable "aws_region" {
  type = string
  description = "The AWS region to deploy the resources to. Default: us-west-2"
  default = "us-west-2"
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

# TFE
variable "tfe_organization_name" {
  type = string
}