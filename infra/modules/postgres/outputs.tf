
output "postgres_db_endpoint" {
  value = aws_db_instance.postgres_instance.endpoint
}

output "postgres_db_credentials_secret_id" {
  value = aws_secretsmanager_secret.postgres_db_credentials.id
}
