#!/bin/bash

set -euo pipefail

source ~/.bashrc

HCP_PROJECT_ID=`terraform output -state=$TF_BASE/setup/terraform.tfstate -raw hcp_project_id`
HCP_ORG_ID=`terraform output -state=$TF_BASE/setup/terraform.tfstate -raw hcp_org_id`

token=$(curl -s --location https://auth.idp.hashicorp.com/oauth2/token \
    --header "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "client_id=$TF_VAR_hcp_client_id" \
    --data-urlencode "client_secret=$TF_VAR_hcp_client_secret" \
    --data-urlencode "grant_type=client_credentials" \
    --data-urlencode "audience=https://api.hashicorp.cloud" \
    | jq -r '.access_token')
curl -s -X DELETE \
     -H "Authorization: Bearer $token" \
    https://api.cloud.hashicorp.com/packer/2023-01-01/organizations/$HCP_ORG_ID/projects/$HCP_PROJECT_ID/registry

cd ${TF_BASE}/setup
terraform state rm module.autobahn-demo-vpc
terraform state rm hcp_packer_run_task.registry
terraform destroy -auto-approve