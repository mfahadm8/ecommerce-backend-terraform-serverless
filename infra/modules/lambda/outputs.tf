output "create_order_lambda_arn" {
  value       = aws_lambda_function.create_order_function.arn
  description = "Arn of Order Create Function"
}

output "get_customer_orders_lambda_arn" {
  value       = aws_lambda_function.get_customer_orders_function.arn
  description = "Arn of Get Customer Orders Function"
}
