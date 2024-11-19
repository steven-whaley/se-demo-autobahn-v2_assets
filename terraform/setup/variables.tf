# AWS
variable "aws_region" {
  type = string
  default = "us-west-2"
}

variable "aws_access_key_id" {
  type = string
  description = "AWS Access Key ID"
}

variable "aws_secret_access_key" {
  type = string
  description = "AWS Secret Access Key"
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