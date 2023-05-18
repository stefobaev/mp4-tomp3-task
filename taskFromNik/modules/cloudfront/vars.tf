variable "bucketName" {}
variable "bucket_name" {}
variable "bucket_arn" {}
variable "certificateArn" {
    default = "your-certificate-arn"
}

variable "cloudFrontComment" {
    default = " Society CloudFront distribution"
}

variable "cloudFrontDefaultRootObject" {
    default = "index.html"
}

variable "cloudFrontCertificateVersion" {
    default = "TLSv1.2_2021"
}

variable "hostedZoneId" {
    default = "your-hosted-zone"
}
