variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
  default     = "markaz-cognito-user-pool"
}

variable "cognito_web_client_id" {
  description = "Client Name for Web Access"
  type        = string
  default     = "web-client"
}

variable "user_pool_web_client_secret_name" {
  description = "Name of the Cognito User Pool Client"
  type        = string
  default     = "ecommerce/backend/auth/clientsecret"
}

variable "user_pool_secret_name" {
  description = "Name of the Cognito User Pool"
  type        = string
  default     = "ecommerce/backend/auth/userpool"
}

// Variables for the Postgres module
variable "db_instance_identifier" {
  type    = string
  default = "ecommerce-pg-db"
}

variable "db_name" {
  description = "Name of the PostgresDB"
  type        = string
  default     = "ecommerce-db"
}

variable "db_username" {
  description = "Username for accessing the PostgresDB"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password for accessing the PostgresDB"
  type        = string
  default     = "Admin@123"
}

variable "db_username_secret_name" {
  description = "Secrets Manager Secret Name for storing DB Username for accessing the PostgresDB"
  type        = string
  default     = "ecommerce/backend/auth/dbusername"
}

variable "db_password_secret_name" {
  description = "Secrets Manager Secret Name for storing DB Password for accessing the PostgresDB"
  type        = string
  default     = "ecommerce/backend/auth/dbpassword"
}

// Variables for the Lambda Functions module
variable "create_order_function_name" {
  description = "Name of the CreateOrder Lambda function"
  type        = string
  default     = "CreateOrderFunction"
}

variable "get_customer_orders_function_name" {
  description = "Name of the GetCustomerOrders Lambda function"
  type        = string
  default     = "GetCustomerOrders"
}

variable "process_orders_function_name" {
  description = "Name of the ProcessOrdersFunction Lambda function"
  type        = string
  default     = "ProcessOrdersFunction"
}

variable "update_stocks_function_name" {
  description = "Name of the UpdateStockFunction Lambda function"
  type        = string
  default     = "UpdateStocksFunction"

}
// Variables for the SQS module
variable "update_stocks_queue_name" {
  description = "SQS Queue for Updating Stock Information"
  type        = string
  default     = "update-stocks-queue"
}

variable "order_processing_queue_name" {
  description = "SQS Queue for Order Processing"
  type        = string
  default     = "order-processing-queue"
}

// Variables for the API Gateway module
variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "ecommerce-backend"
}


