packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "version" {
  type    = string
  default = "1.1.0"
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

data "amazon-ami" "ubuntu-focal" {
  region = var.aws_region
  filters = {
    name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "basic-example" {
  region         = var.aws_region
  source_ami     = data.amazon-ami.ubuntu-focal.id
  instance_type  = "t3.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "autobahn_web_{{timestamp}}_v${var.version}"

  vpc_filter {
    filters = {
      "tag:Name": "autobahn-v2-vpc"
    }
  }

  subnet_filter {
    filters = {
      "tag:Name": "autobahn-v2-subnet"
    }
    random = true
  }

  associate_public_ip_address = true
}

build {
  hcp_packer_registry {
    bucket_name = "ubuntu-base"
    description = <<EOT
The base image our applications source from
    EOT
    bucket_labels = {
      "owner"          = "platform-team"
      "os"             = "Ubuntu",
      "ubuntu-version" = "Focal 20.04",
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
      "version"      = "v${var.version}"
    }
  }
  sources = [
    "source.amazon-ebs.basic-example"
  ]

  provisioner "shell" {
    inline = [
        "echo Installing Apache",
        "sleep 30",
        "sudo apt-get update",
        "sudo apt-get install -y apache2",
        "sudo rm /var/www/html/index.html",
        "echo '<h1>Hello World!</h1>' > /tmp/index.html",
        "echo '<body>You are using Packer Image Version ${var.version}</body>' >> /tmp/index.html",
        "sudo cp /tmp/index.html /var/www/html/",
    ]
  }
}
