output "api_gateway_invoke_url" {
  value = module.api_gateway.invoke_url
}

output "postgres_db_endpoint" {
  value = module.postgres.postgres_db_endpoint
}

output "postgres_db_credentials_secret_id" {
  value =  module.postgres.postgres_db_credentials.id
}
