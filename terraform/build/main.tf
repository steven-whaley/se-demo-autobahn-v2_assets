
data "hcp_packer_version" "ubuntu" {
  project_id   = var.hcp_project_id
  bucket_name  = "ubuntu-base"
  channel_name = "latest"
}

data "hcp_packer_artifact" "ubuntu_this_region" {
  project_id  = var.hcp_project_id
  bucket_name = "ubuntu-base"
  platform    = "aws"
  version_fingerprint = data.hcp_packer_version.ubuntu.fingerprint
  region              = var.aws_region
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "swkey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFzzLNTZnW40ZyXOsI7IhfGxhsalitHspxxkO9rDKvRAaqAA6a8hLbQoV69XrH98h7uCKc791vAIMV7q45tFaLBGRsOUjhS4BORKW1CB3X9Y44YrkbvkV2nuKHfTRbItCI5JPliBOkl/hBDgCH963x//7BzBzkhf12XAMphQKYkUq8xBYwc5cfF4UlJSFQtOspgFQyOh1yGmosJEv2XLDiylKy74wc9DhVjeQlGQj4aO1iW4P7tFC5Z45uSoV/vEJVkN+SvgjoKbNw0UztBT4wSnKqElbT4/jO7hAnSzxYR+6DOD8UaC8mgGU25s2stMBILzZlndWmHk1+DA39lm4ZjOY/rQrbQK0DMuOVE6aU1xkenkfdtIBEVIMWKAHrVbjZ8C6/V63yLTAJzABv4MKHmZPYe1GjeiExJftGml44KRsIhuasVRTiS2Zt3AkqigyEkwgErdhYfnOyfjm5Vu8FiuTDowi8clNiTASlA9+wdlE7tylIUsomhrBG+aRvlE0= swhaley@swhaley-M43L9KG44N"
}

# resource "aws_instance" "demo" {
#   ami           = data.hcp_packer_artifact.ubuntu_this_region.external_identifier
#   instance_type = "t3.small"
#   subnet_id     = module.autobahn-demo-vpc.public_subnets[0]
#   associate_public_ip_address = true
#   key_name = aws_key_pair.ssh-key.key_name
#   security_groups = [module.web-sec-group.security_group_id]
#   tags = {
#     Name = "Demo App Server"
#   }
# }

module "web-sec-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name   = "web-server-sec-group"
  vpc_id = var.vpc_id

  ingress_with_source_security_group_id = [
    {
        rule = "http-80-tcp"
        description = "Allow HTTP from load balancer"
        source_security_group_id = module.lb-sec-group.security_group_id
    }
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["https-443-tcp", "http-80-tcp"]
}

module "lb-sec-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name   = "lb-sec-group"
  vpc_id = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = ["http-80-tcp"]

  egress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      description              = "Allow HTTP target group"
      source_security_group_id = module.web-sec-group.security_group_id
    },
  ]
}

# Load Balancer Config
resource "aws_lb" "webapp_lb" {
  name               = "autobahn-demo-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnets
  security_groups = [module.lb-sec-group.security_group_id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "webapp_targets" {
  name     = "autobahn-demo-webapp-targets"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_autoscaling_attachment" "webapp_attachment" {
    autoscaling_group_name = aws_autoscaling_group.webapp.name
    lb_target_group_arn = aws_lb_target_group.webapp_targets.arn
}

resource "aws_lb_listener" "webapp_listener" {
  load_balancer_arn = aws_lb.webapp_lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_targets.arn
  }
}

resource "aws_launch_template" "webapp" {
  name_prefix   = "webapp"
  image_id      = data.hcp_packer_artifact.ubuntu_this_region.external_identifier
  instance_type = "t3.small"
  update_default_version = true

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [module.web-sec-group.security_group_id]
  }
}

resource "aws_autoscaling_group" "webapp" {
  name                      = "webapp-autobahn-demo"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 120
  health_check_type         = "ELB"
  desired_capacity          = 2
  
 launch_template {
    id      = aws_launch_template.webapp.id
    version = aws_launch_template.webapp.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
        min_healthy_percentage = 50
        skip_matching = true
    }
  }
  
  vpc_zone_identifier       = var.public_subnets

  instance_maintenance_policy {
    min_healthy_percentage = 50
    max_healthy_percentage = 150
  }

  timeouts {
    delete = "15m"
  } 
}

