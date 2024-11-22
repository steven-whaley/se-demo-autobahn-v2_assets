data "terraform_remote_state" "setup" {
    backend = "local"
    config = {
        path = "../setup/terraform.tfstate"
    }
}

data "hcp_packer_version" "terramino" {
  project_id   = data.terraform_remote_state.setup.outputs.hcp_project_id
  bucket_name  = "autobahn-v2-demo-terramino"
  channel_name = "latest"
}

resource "hcp_packer_channel_assignment" "Production" {
  project_id   = data.terraform_remote_state.setup.outputs.hcp_project_id
  bucket_name         = "autobahn-v2-demo-terramino"
  channel_name        = "Production"
  version_fingerprint = data.hcp_packer_version.terraform.fingerprint
}