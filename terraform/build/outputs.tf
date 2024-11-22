output "webapp_url" {
  description = "The URL where you can reach the web app"
  value       = "http://${aws_lb.webapp_lb.dns_name}"
}

output "ami_id" {
  description = "The AMI of the image we created with packer"
  value = data.hcp_packer_artifact.terramino_this_region.external_identifier
}