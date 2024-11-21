variable "aws_region" {
  type        = string
  description = "The AWS region to deploy the resources to. Default: us-west-2"
  default     = "us-west-2"
}

variable "vpc_id" {
  type = string
}

variable "hcp_project_id" {
  type = string
}

variable "public_subnets" {
  type = tuple([string, string])
}

variable "public_key" {
  type = string
}