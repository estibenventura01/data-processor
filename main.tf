terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "3.0.0"
    }
  }
}

provider "linode" {
    token = var.token
}

resource "linode_instance" "data-process" {
    label = "dataproc_assignment"
    image = "linode/ubuntu22.04"
    region = "var.region"
    type = "g6-standard-1"
    authorized_keys = [var.authorized_keys]
    root_pass = var.root_pass
}

resource "linode_firewall" "dataproc" {
  label = "dataproc-fw"

  inbound {
    label    = "allow-ssh"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"]
  }

  inbound {
    label    = "allow-app"
    protocol = "TCP"
    ports    = "8080"
    ipv4     = ["0.0.0.0/0"]
  }

  linodes = [linode_instance.dataproc.id]
}
