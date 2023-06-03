
# modules/cognito/main.tf

resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name


  lifecycle {
    create_before_destroy = true
    ignore_changes        = [user_pool_name]
  }

  # Store the user pool ID in Secrets Manager  
  provisioner "local-exec" {
    command = <<-EOT
      aws secretsmanager create-secret \
        --name ${var.user_pool_secret_name} \
        --secret-string '${aws_cognito_user_pool.user_pool.id}'
    EOT
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name                     = var.user_pool_web_client_name
  user_pool_id             = aws_cognito_user_pool.user_pool.id
  generate_secret          = true
  allowed_oauth_flows      = ["code"]
  allowed_oauth_scopes     = ["openid", "email", "profile"]
  allowed_oauth_flows_user_pool_client = true 


  # Store the user pool client secret in Secrets Manager
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [user_pool_client_name]
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws secretsmanager create-secret \
        --name ${var.user_pool_web_client_secret_name} \
        --secret-string '${aws_cognito_user_pool_client.user_pool_client.client_secret}'
    EOT
  }
}


