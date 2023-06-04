variable "region" {
  description = "Aws region"
}
variable "account_id" {
  description = "Current Aws Account Id"
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = []
}
variable "create_order_function_name" {
  description = "Name of the CreateOrderFunction Lambda"
  type        = string
}

variable "get_customer_orders_function_name" {
  description = "Name of the GetCustomerOrdersFunction Lambda"
  type        = string
}

variable "process_order_function_name" {
  description = "Name of the ProcessOrderFunction Lambda"
  type        = string
}

variable "update_stocks_function_name" {
  description = "Name of the UpdateStocksFunction Lambda"
  type        = string
}

variable "pg_creds_secret_name" {
  description = "Secrets Manager Secret Name for storing DB Username for accessing the PostgresDB"
  type        = string
}

variable "order_processing_queue_name" {
  description = "SQS Queue for Processing Orders"
  type        = string
}
variable "update_stocks_queue_name" {
  description = "SQS Queue for Updating Stocks"
  type        = string
}

variable "lambda_security_group_id" {
  description = "Security group for Lambda Functions"
  type        = string
}
