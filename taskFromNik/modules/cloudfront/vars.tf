variable "bucketName" {}
variable "bucket_name" {}
variable "bucket_arn" {}
variable "certificateArn" {
    default = "arn:aws:acm:us-east-1:089370973671:certificate/958fcc72-7152-452c-9eab-0fc4af91856f"
}

variable "cloudFrontComment" {
    default = "Baev Society CloudFront distribution"
}

variable "cloudFrontDefaultRootObject" {
    default = "index.html"
}

variable "cloudFrontCertificateVersion" {
    default = "TLSv1.2_2021"
}

variable "hostedZoneId" {
    default = "Z0637605ZR276D7FVLBB"
}