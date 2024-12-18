
data "hcp_packer_artifact" "terramino_this_region" {
  project_id          = var.hcp_project_id
  bucket_name         = "autobahn-v2-demo-terramino"
  platform            = "aws"
  channel_name = "Production"
  region              = var.aws_region
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "autobahn-v2-key"
  public_key = var.public_key
}

module "web-sec-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name   = "web-server-sec-group"
  vpc_id = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      description              = "Allow HTTP from load balancer"
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
  ingress_rules       = ["http-80-tcp", "ssh-tcp"]

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
  security_groups    = [module.lb-sec-group.security_group_id]

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
  lb_target_group_arn    = aws_lb_target_group.webapp_targets.arn
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
  name_prefix            = "webapp"
  image_id               = data.hcp_packer_artifact.terramino_this_region.external_identifier
  instance_type          = "t3.small"
  update_default_version = true
  key_name               = aws_key_pair.ssh-key.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [module.web-sec-group.security_group_id]
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
      skip_matching          = true
    }
  }

  vpc_zone_identifier = var.public_subnets

  instance_maintenance_policy {
    min_healthy_percentage = 50
    max_healthy_percentage = 150
  }

  timeouts {
    delete = "15m"
  }
}

