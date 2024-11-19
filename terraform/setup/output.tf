output "hcp_project_id" {
  description = "Project ID of the HCP Project we created"
  value = hcp_project.demo.resource_id
}

output "hcp_org_id" {
  description = "The ID of the HCP Organization"
  value = data.hcp_organization.demo.resource_id
}

output "vpc_id" {
  description = "The ID of the VPC we created"
  value = module.autobahn-demo-vpc.vpc_id
}

output "private_subnets" {
  description = "The list of private subnets we created"
  value = module.autobahn-demo-vpc.private_subnets
}

output "public_subnets" {
  description = "The list of public subnets we created"
  value = module.autobahn-demo-vpc.public_subnets
}