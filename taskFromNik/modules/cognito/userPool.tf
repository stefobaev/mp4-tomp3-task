resource "aws_cognito_user_pool" "myPool" {
    name = var.poolName

  # Sign-in options
    username_attributes = ["email"]
  
  # MFA enforcement
    mfa_configuration = var.mfaConf

  # Additional required attributes
    schema {
        name = var.attrName
        attribute_data_type = var.attrType
        required = true
    }

  # Email provider
    email_configuration {
        email_sending_account = var.mailSendConf
    }

  # Hosted authentication pages
    account_recovery_setting {
        recovery_mechanism {
            name = var.recoveryMech
            priority = 1
        }
    }
    auto_verified_attributes = ["email"]
}

# Cognito domain
resource "aws_cognito_user_pool_domain" "myPoolDomain" {
  domain       = var.domainName
  user_pool_id = aws_cognito_user_pool.myPool.id
}

resource "aws_cognito_user_pool_client" "myApp" {
    name = var.appName
    user_pool_id = aws_cognito_user_pool.myPool.id

    # App client settings
    generate_secret                      = false
    explicit_auth_flows                  = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_CUSTOM_AUTH"]
    prevent_user_existence_errors        = var.preventUser
    refresh_token_validity               = var.tokenValidity
    allowed_oauth_flows                  = ["code"]
    callback_urls                        = ["https://your-domain.com"]
    allowed_oauth_scopes                 = ["openid", "email", "phone"]
    supported_identity_providers         = ["COGNITO"]
    allowed_oauth_flows_user_pool_client = true
}

data "aws_cognito_user_pool_client" "clientidname" {
  user_pool_id  = aws_cognito_user_pool.myPool.id
  client_id     = aws_cognito_user_pool_client.myApp.id
}

output "clientidnameOutput" {
  value = data.aws_cognito_user_pool_client.clientidname.client_id
}

output "userPoolId" {
  value = aws_cognito_user_pool.myPool.id
}

output "clientId" {
  value = aws_cognito_user_pool_client.myApp.id
}
