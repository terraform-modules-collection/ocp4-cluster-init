provider "aws" {
  region = "us-east-1"
}

provider "minio" {
  minio_server = var.minioServer
  minio_access_key = var.minioAccessKey
  minio_secret_key = var.minioSecretKey
}

terraform {
  backend "s3" {
    bucket = "tf-states-s3"
    key    = "cluster-init"
    region = "us-east-1"
  }
}

locals {
  publicBucketName = "ocp-cluster-${var.clusterName}-public"
  privateBucketName = "ocp-cluster-${var.clusterName}-private"
}

resource "minio_s3_bucket" "public-bucket" {
  bucket = local.publicBucketName
  acl    = "public"
}

resource "minio_s3_bucket" "private-bucket" {
  bucket = local.privateBucketName
  acl    = "private"
}

resource "null_resource" "init-cluster" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/init-cluster.sh"
    environment = {
        WORKDIR = "${path.module}/init-cluster/${var.clusterName}"
        CLUSTER_NAME = var.clusterName
        PULL_SECRET_B64 = var.pullSecret
        SSH_PUB_KEY_B64 = var.sshPubKey
        BASE_DOMAIN = var.baseDomain
        PUBLIC_BACKET_NAME = minio_s3_bucket.public-bucket.id
        PRIVATE_BACKET_NAME = minio_s3_bucket.private-bucket.id
        MINIO_SERVER = var.minioServer
        MINIO_ACCESS_KEY = var.minioAccessKey
        MINIO_SECRET_KEY = var.minioSecretKey
    }
  }
}

output "workerIgnUrl" {
  value = "http://${var.minioServer}/${minio_s3_bucket.public-bucket.id}/worker.ign"
}
output "masterIgnUrl" {
  value = "http://${var.minioServer}/${minio_s3_bucket.public-bucket.id}/master.ign"
}

output "bootstrapIgnUrl" {
  value = "http://${var.minioServer}/${minio_s3_bucket.public-bucket.id}/bootstrap.ign"
}
