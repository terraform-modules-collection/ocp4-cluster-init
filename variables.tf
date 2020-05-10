variable "clusterName" {
  type = string
  description = "OpenShift cluster name"
}

variable "baseDomain" {
  type = string
  description = "Base organization  domain"
}

variable "pullSecret" {
  type = string
  description = "RedHat registry pull secret"
}

variable "sshPubKey" {
  type = string
  description = "SSH public key for ssh access to cluster nodes"
}

variable "minioServer" {
  type = string
  description = "Minio S3 server hostname without schema"
}
variable "minioAccessKey" {
  type = string
  description = "S3 access key"
}
variable "minioSecretKey" {
  type = string
  description = "S3 secret key"
}

