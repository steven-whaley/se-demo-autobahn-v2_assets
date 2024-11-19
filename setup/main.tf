
# Create the HCP Project and registry

data "hcp_organization" "demo" {
}

resource "hcp_project" "demo" {
  name = "autobahn-v2-prj"
}

resource "terraform_data" "activate_packer_registry" {
  triggers_replace = [hcp_project.demo.resource_id]

  provisioner "local-exec" {
    command = <<EOF
      #!/usr/bin/env bash

      set -e # this ensures that if any of the commands fail the entire thing fails

      token=$(curl -s --location https://auth.idp.hashicorp.com/oauth2/token \
        --header "Content-Type: application/x-www-form-urlencoded" \
        --data-urlencode "client_id=${var.hcp_client_id}" \
        --data-urlencode "client_secret=${var.hcp_client_secret}" \
        --data-urlencode "grant_type=client_credentials" \
        --data-urlencode "audience=https://api.hashicorp.cloud" \
      | jq -r '.access_token')
      curl -s -X PUT \
        -H "Authorization: Bearer $token" \
        -d '{"feature_tier": "STANDARD"}' \
        https://api.cloud.hashicorp.com/packer/2023-01-01/organizations/${data.hcp_organization.demo.resource_id}/projects/${hcp_project.demo.resource_id}/registry
        sleep 5 # to allow the registry to activate before the packer builds start
      EOF
  }
}

# Create the HCP Packer run task in HCPTF

resource "hcp_packer_run_task" "registry" {
  depends_on = [ terraform_data.activate_packer_registry ]
  project_id = hcp_project.demo.resource_id
}

resource "tfe_organization_run_task" "packer" {
  organization = var.tfe_organization_name
  url          = hcp_packer_run_task.registry.endpoint_url
  name         = "autobahn-v2-packer"
  enabled      = true
  description  = "A run task for demostrating Packer/TF Autobahn integration"
  hmac_key = hcp_packer_run_task.registry.hmac_key
}


### Create the Workspace in HCPTF that will be run create AWS resources ###
resource "tfe_project" "demo_project" {
  name = "autobahn-v2-prj"
}

resource "tfe_workspace" "demo_workspace" {
  name = "autobahn-demo-main"
  project_id = tfe_project.demo_project.id
}

resource "tfe_workspace_run_task" "packer" {
  workspace_id      = tfe_workspace.demo_workspace.id
  task_id           = tfe_organization_run_task.packer.id
  enforcement_level = "mandatory"
  stages = ["post_plan"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "autobahn-demo-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  name = "autobahn-v2-vpc"
  cidr = "172.25.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["172.25.1.0/24", "172.25.2.0/24"]
  public_subnets  = ["172.25.11.0/24", "172.25.12.0/24"]

  create_igw = true
  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true

  public_subnet_tags = {
    Name = "autobahn-v2-subnet"
  }

  vpc_tags = {
    Name = "autobahn-v2-vpc"
  }
}