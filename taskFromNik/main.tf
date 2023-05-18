provider "aws" {
  region = var.region
}

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "4.65.0"
        }
    }
}

module "ses" {
    source = "./modules/ses"
}

module "cert" {
    source = "./modules/certificate"
}

module "s3" {
    source     = "./modules/s3"
    depends_on = [module.cert]
}

module "cognito" {
    source     = "./modules/cognito"
    userPoolId = module.cognito.userPoolId
    clientId   = module.cognito.clientId
    depends_on = [module.s3]
}

module "uploadIndex" {
    source           = "./modules/index"
    region           = var.region
    clientId         = module.cognito.clientId
    identity_pool_id = module.cognito.identity_pool_id
    userPoolId       = module.cognito.userPoolId
    bucketName       = module.s3.bucket_name
    depends_on       = [module.cognito]
}

module "cloudfront" {
    source      = "./modules/cloudfront"
    bucket_name = module.s3.bucket_name
    bucket_arn  = module.s3.bucket_arn
    bucketName  = module.s3.bucketName
    depends_on  = [module.uploadIndex]
}

module "queque" {
    source = "./modules/queque"
}

module "firstLambada" {
    source      = "./modules/firstlambda"
    bucketName  = module.s3.bucket_name
    bucket_arn  = module.s3.bucket_arn
    queueUrl    = module.queque.queueUrl
    depends_on  = [module.cloudfront, module.queque]
}

module "secondLambada" {
    source         = "./modules/secondlambada"
    bucketName     = module.s3.bucket_name
    bucket_arn     = module.s3.bucket_arn
    queueArn       = module.queque.queueArn
    awslambdafunc1 = module.firstLambada.awslambdafunc1
    depends_on     = [module.firstLambada]
}