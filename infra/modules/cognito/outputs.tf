output "user_pool_client_id" {
  value       = aws_cognito_user_pool_client.user_pool_client.id
  description = "Cognito User Pool Client ID"
}

output "user_pool_client_secret" {
  value       = aws_cognito_user_pool_client.user_pool_client.client_secret
  description = "Cognito User Pool Client Secret"
}

output "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.user_pool.arn
}