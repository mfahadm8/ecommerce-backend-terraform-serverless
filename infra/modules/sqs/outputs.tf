output "order_processing_queue_url" {
  description = "SQS Queue URL for Order Processing"
  value        = aws_sqs_queue.order_processing_queue.url
}

output "update_stocks_queue_url" {
  description = "SQS Queue URL for Processing Orders"
  value        = aws_sqs_queue.update_stocks_queue.url
}