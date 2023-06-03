output "user_pool_client_id" {
  value       = aws_cognito_user_pool_client.user_pool_client.id
  description = "Cognito User Pool Client ID"
}

output "user_pool_client_secret" {
  value       = aws_cognito_user_pool_client.user_pool_client.client_secret
  description = "Cognito User Pool Client Secret"
}