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

export PACKER_BASE="$(pwd)/se-demo-autobahn-v2_assets/packer"
echo "export PACKER_BASE=\"$PACKER_BASE\"" >> ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh

echo "export TF_VAR_aws_access_key_id=$AWS_ACCESS_KEY_ID" >> ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh
echo "export TF_VAR_aws_secret_access_key='$AWS_SECRET_ACCESS_KEY'" >> ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh

default_setup_info_text=\
"This script sets up HCP Packer and TF 
"

echo "$default_setup_info_text"
echo ""

echo "Please provide your HCP Client ID: "
read hcp_client_id
export HCP_CLIENT_ID=$hcp_client_id 
echo "export TF_VAR_hcp_client_id=\"$hcp_client_id\"" >> ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh
echo ""

echo "Please provide your HCP Client Secret: "
read -s hcp_client_secret
export HCP_CLIENT_SECRET=$hcp_client_secret
echo "export TF_VAR_hcp_client_secret=\"$hcp_client_secret\"" >> ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh
echo ""

echo "Please provide your HCP Terraform Organization Name: "
read tfe_org
echo "export TF_VAR_tfe_org=\"$tfe_org\"" >> ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh
echo ""

# Update org name in cloud block
sed -i -e "s/placeholder1234/$tfe_org/g" ${TF_BASE}/build/providers.tf

echo "Please provide your HCP Terraform token: "
read -s tfe_token
echo "export TFE_TOKEN=\"$tfe_token\"" >> ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh
echo ""

# Write terraform credentials file for remote apply
if [ ! -d ${HOME}/.terraform.d ]; then
    mkdir .terraform.d
    cat <<EOF >> .terraform.d/credentials.tfrc.json
{
  "credentials": {
    "app.terraform.io": {
      "token": "$tfe_token"
    }
  }
}
EOF
fi

echo "export TF_VAR_public_key=\"$(cat ~/.ssh/id_rsa.pub)\"" >> ~/.${INSTRUQT_PARTICIPANT_ID}-env.sh

source .bashrc

cd ${TF_BASE}/setup
terraform init
terraform apply -auto-approve
if [ $? -eq 0 ]; then
  touch ${HOME}/.setup-success
fi

export HCP_PROJECT_ID=`terraform output -raw hcp_project_id`

# Allow to not rerun packer
if [ -f ${HOME}/.packer-success ]; then
  echo "Rerun packer? Enter 'yes' to rerun."
  read rerun_packer
  if [ "$rerun_packer" == "yes" ]; then
    cd ${PACKER_BASE}
    packer init .
    packer build .
    if [ $? -eq 0 ]; then
        touch ${HOME}/.packer-success
    fi
  fi
fi  