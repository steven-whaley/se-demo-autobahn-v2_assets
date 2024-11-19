#!/bin/bash

set -euo pipefail

if [[ -f ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh ]]; then
  rm ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh
  touch ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh
else
  touch ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh
fi

if ! grep -E "^source ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh$" ~/.bashrc > /dev/null 2>&1; then
  echo "" >> ~/.bashrc
  echo "source ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh" >> ~/.bashrc
fi

export TF_BASE="$(pwd)/se-demo-autobahn-v2_assets/terraform"
echo "export TF_BASE=\"$TF_BASE\"" >> ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh

default_setup_info_text=\
"This script sets up HCP Packer and TF 
"

echo "$default_setup_info_text"
echo ""

echo "Please provide your HCP Client ID: "
read hcp_client_id
echo "export TF_VAR_hcp_client_id=\"$hcp_client_id\"" >> ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh
echo ""

echo "Please provide your HCP Client Secret: "
read -s hcp_client_secret
echo "export TF_VAR_hcp_client_secret=\"$hcp_client_secret\"" >> ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh
echo ""

echo "Please provide your HCP Terraform Organization Name: "
read -s tfe_org
echo "export TF_VAR_tfe_org=\"$tfe_org\"" >> ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh
echo ""

echo "Please provide your HCP Terraform token: "
read -s tfe_token
echo "export TFE_TOKEN=\"$tfe_token\"" >> ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh
echo ""

echo "export TF_VAR_public_key=\"$(cat ~/.ssh/id_rsa.pub)\"" >> ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh

source .bashrc

# cd ${TF_BASE}/boundary-demo-init
# terraform init
# terraform apply -auto-approve
# if [ $? -eq 0 ]; then
#   touch ${HOME}/.init-success
# fi

# cd ${TF_BASE}/boundary-demo-targets
# terraform init
# terraform apply -auto-approve
# if [ $? -eq 0 ]; then
#   touch ${HOME}/.targets-success
# fi

