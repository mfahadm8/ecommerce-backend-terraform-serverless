variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "create_order_lambda_arn" {
  description = "ARN of the CreateOrderFunction Lambda"
  type        = string
}

variable "get_customer_orders_lambda_arn" {
  description = "ARN of the GetCustomerOrdersFunction Lambda"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  type        = string
}
