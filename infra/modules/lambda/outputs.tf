output "order_create_function_arn" {
value = aws_lambda_function.create_order_function.arn
description = "Arn of Order Create Function"
}

output "order_create_function_arn" {
value = aws_lambda_function.get_customer_orders_function
description = "Arn of Get Customer Orders Function"
}