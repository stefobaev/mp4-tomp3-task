resource "aws_cognito_identity_pool" "example" {
  identity_pool_name = var.identityName

  # Enable unauthenticated access
  allow_unauthenticated_identities = true

  # Configure the Amazon Cognito Identity Provider
  cognito_identity_providers {
    provider_name           = "cognito-idp.eu-central-1.amazonaws.com/${var.userPoolId}"
    client_id               = var.clientId
    server_side_token_check = false
  }
}

# Create an IAM role with full S3 access
resource "aws_iam_role" "baevRoleForCognito" {
  name = "example_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          "StringEquals": {
          "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.example.id
          },
          "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
          }
        }
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "baevrolePolicy" {
  name_prefix = "baevPolicy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "s3:*",
          "mobileanalytics:PutEvents",
          "cognito-sync:*",
          "cognito-identity:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
  role        = aws_iam_role.baevRoleForCognito.name
}


# Attach the AmazonS3FullAccess policy to the IAM role
resource "aws_iam_role_policy_attachment" "s3_full_access_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.baevRoleForCognito.id
}

# Attach the IAM role with full S3 access to the Cognito authenticated role
resource "aws_cognito_identity_pool_roles_attachment" "example" {
  identity_pool_id = aws_cognito_identity_pool.example.id
  roles = {
    "authenticated" = aws_iam_role.baevRoleForCognito.arn
    "unauthenticated" = aws_iam_role.baevRoleForCognito.arn
  }
}

output "identity_pool_id" {
  value = aws_cognito_identity_pool.example.id
}