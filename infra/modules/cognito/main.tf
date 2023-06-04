resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name

  # Store the user pool ID in Secrets Manager  
  provisioner "local-exec" {
    command = <<-EOT
      aws secretsmanager create-secret \
        --name ${var.user_pool_secret_name} \
        --secret-string '${aws_cognito_user_pool.user_pool.id}'
    EOT
  }
}

resource "aws_cognito_resource_server" "resource_server" {
  name         = "cognito_resource_server"
  identifier   = "https://api.markaz.com"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  scope {
    scope_name        = "all"
    scope_description = "Get access to all API Gateway endpoints."
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name                                 = var.user_pool_web_client_name
  user_pool_id                         = aws_cognito_user_pool.user_pool.id
  generate_secret                      = true
  allowed_oauth_flows                  = ["client_credentials"]
  supported_identity_providers         = ["COGNITO"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = [join(",", aws_cognito_resource_server.resource_server.scope_identifiers)]

  depends_on = [
    aws_cognito_user_pool.user_pool,
    aws_cognito_resource_server.resource_server,
  ]

  # Store the user pool client secret in Secrets Manager
  provisioner "local-exec" {
    command = <<-EOT
      aws secretsmanager create-secret \
        --name ${var.user_pool_web_client_secret_name} \
        --secret-string '${aws_cognito_user_pool_client.user_pool_client.client_secret}'
    EOT
  }
}
