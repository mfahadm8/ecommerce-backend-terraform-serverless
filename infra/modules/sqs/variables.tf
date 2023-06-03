// Variables for the SQS module
variable "update_stocks_queue_name" {
  description = "SQS Queue for Order Creation"
  type        = string
}

variable "order_processing_queue_name" {
  description = "SQS Queue for Order Processing"
  type        = string

}

variable "process_orders_function_name" {
  description = "Name of the ProcessOrdersFunction Lambda function"
  type        = string
  default = "ProcessOrdersFunction"
}

variable "update_stocks_function_name" {
  description = "Name of the UpdateStockFunction Lambda function"
  type = string
  default = "UpdateStocksFunction"

}