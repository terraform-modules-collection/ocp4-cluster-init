provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "tf-states-s3"
    key    = "cluster-init"
    region = "us-east-1"
  }
}
data "template_file" "install-config" {
  template = file("${path.module}/templates/install-config.yaml")
  vars = {
    clusterName = var.clusterName
    pullSecret = var.pullSecret
    sshPubKey = var.sshPubKey
    baseDomain = var.baseDomain
  }
}

resource "null_resource" "init-cluster" {
  provisioner "local-exec" {
    command = ""
  }
}
