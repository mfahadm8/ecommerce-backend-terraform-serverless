variable "region" {
  description = "Aws region"
}
variable "account_id" {
  description = "Current Aws Account Id"
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

variable "db_username_secret_name" {
  description = "Secrets Manager Secret Name for storing DB Username for accessing the PostgresDB"
  type        = string
}

variable "db_password_secret_name" {
  description = "Secrets Manager Secret Name for storing DB Password for accessing the PostgresDB"
  type        = string
}

variable "db_password_secret_name" {
  description = "Secrets Manager Secret Name for storing DB Password for accessing the PostgresDB"
  type        = string
}

variable "orders_creation_queue_name" {
  description = "SQS Queue for Order Creation"
  type        = string
  default = "order-creation-queue"
}

variable "order_processing_queue_name" {
  description = "SQS Queue for Order Processing"
  type        = string
  default = "order-processing-queue"
}