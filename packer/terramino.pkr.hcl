packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

#Variables cannot be updated during runtime
#This variable is used for the ami_name
variable "ami_prefix" {
  type    = string
  default = "autobahn-v2-demo"
}

variable "version" {
  type    = string
  default = "1.0.0"
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

#Locals are useful when you need to format commanly used values
#
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "amazon-linux" {
  ami_name      = "${var.ami_prefix}-terramino-${local.timestamp}"
  instance_type = "t2.micro"
  region        = var.aws_region
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["137112412989"] # This is the AWS account ID for Amazon Linux 2024
  }
  ssh_username = "ec2-user"

  vpc_filter {
    filters = {
      "tag:Name" : "autobahn-v2-vpc"
    }
  }

  subnet_filter {
    filters = {
      "tag:Name" : "autobahn-v2-subnet"
    }
    random = true
  }

  associate_public_ip_address = true
}

build {
  name = "${var.ami_prefix}-terramino-image"

  hcp_packer_registry {
    bucket_name = "${var.ami_prefix}-terramino"
    description = <<EOT
  EC2 image with apache web server on it and terramino app. 
      EOT
    bucket_labels = {
      "owner" = "Autobahn v2 Instruqt Demo"
      "os"    = "Amazon Linux 2024",
      "app"   = "Terramino-app",
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
      "version"      = "v${var.version}"
    }
  }

  sources = [
    "source.amazon-ebs.amazon-linux"
  ]

  provisioner "file" {
    source      = "files"
    destination = "/home/ec2-user"
  }

  provisioner "shell" {
    inline = [
      "echo '*** Installing Apache (httpd)'",
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "echo '*** Completed Installing Apache (httpd)'",
      "sed 's/VAR_VERSION/${var.version}/g' files/basic.html",
      "sudo mv /home/ec2-user/files/* /var/www/html/",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"
    ]
  }
}