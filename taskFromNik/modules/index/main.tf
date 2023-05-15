variable "region" {}
variable "identity_pool_id" {}
variable "clientId" {}
variable "bucketName" {}
variable "userPoolId" {}

locals {
    rendered_index   = templatefile("${path.module}/index.tpl", {
    region           = var.region
    identity_pool_id = var.identity_pool_id
    clientId         = var.clientId
    userPoolId       = var.userPoolId
    bucketName       = var.bucketName
    })
}

resource "aws_s3_bucket_object" "object" {
bucket       = var.bucketName
key          = "index.html"
content      = local.rendered_index
content_type = "text/html"
acl          = "public-read"
}