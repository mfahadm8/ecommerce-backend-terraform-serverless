provider "aws" {
  region = var.aws_region
}
data "aws_caller_identity" "current" {}

module "cognito" {
  source                           = "./modules/cognito"
  user_pool_name                   = var.cognito_user_pool_id
  user_pool_web_client_name        = var.cognito_web_client_id
  user_pool_secret_name            = var.user_pool_secret_name
  user_pool_web_client_secret_name = var.user_pool_web_client_secret_name
}



module "postgres" {
  source                 = "./modules/postgres"
  account_id             = data.aws_caller_identity.current.account_id
  aws_region             = var.aws_region
  db_instance_identifier = var.db_instance_identifier
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
}

module "sqs" {
  source = "./modules/sqs"

  update_stocks_queue_name     = var.update_stocks_queue_name
  order_processing_queue_name  = var.order_processing_queue_name
  process_orders_function_name = var.process_orders_function_name
  update_stocks_function_name  = var.update_stocks_function_name
}

module "lambda" {
  source                            = "./modules/lambda"
  account_id                        = data.aws_caller_identity.current.account_id
  region                            = var.aws_region
  create_order_function_name        = var.create_order_function_name
  get_customer_orders_function_name = var.get_customer_orders_function_name
  process_order_function_name       = var.process_orders_function_name
  update_stocks_function_name       = var.update_stocks_function_name
  db_username_secret_name           = var.db_username_secret_name
  db_password_secret_name           = var.db_password_secret_name
  order_processing_queue_url        = module.lambda.order_processing_queue_url
  update_stocks_queue_url           = module.lambda.update_stocks_queue_url

}

module "api_gateway" {
  source                         = "./modules/api_gateway"
  aws_region                     = var.aws_region
  api_gateway_name               = var.api_gateway_name
  create_order_lambda_arn        = module.lambda.create_order_lambda_arn
  get_customer_orders_lambda_arn = module.lambda.get_customer_orders_lambda_arn
  cognito_user_pool_arn          = module.cognito.cognito_user_pool_arn

}
