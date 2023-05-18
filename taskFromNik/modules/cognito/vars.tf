variable "poolName" {
    default = "myPool"
}

variable "mfaConf" {
    default = "OFF"
}

variable "attrName" {
    default = "phone_number"
}

variable "attrType" {
    default = "String"
}

variable "mailSendConf" {
    default = "COGNITO_DEFAULT"
}

variable "recoveryMech" {
    default = "verified_email"
}

variable "domainName" {
    default = "your-domain"
}

variable "appName" {
    default = "myApp"
}

variable "preventUser" {
    default = "LEGACY"
}

variable "tokenValidity" {
    default = 30
}

variable "identityName" {
    default = "fedNameaev"
}

variable "userPoolId" {}

variable "clientId" {}

variable "awsAccountId" { 
    default = your-acc-id
}
