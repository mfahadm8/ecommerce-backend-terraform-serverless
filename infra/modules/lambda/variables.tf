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
