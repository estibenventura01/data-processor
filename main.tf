terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "3.0.0"
    }
  }
}

provider "linode" {
    token =
}

resource "linode_instance" "data-process" {
    label = "dataproc_assignment"
    image = "linode/ubuntu22.04"
    region = "us-east"
    type = "g6-standard-1"
    authorized_keys = 
    root_pass = 
}
