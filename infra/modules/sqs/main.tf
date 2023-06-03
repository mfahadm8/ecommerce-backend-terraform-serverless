
resource "aws_sqs_queue" "update_stocks_queue" {
  name = var.update_stocks_queue_name
}

resource "aws_sqs_queue" "order_processing_queue" {
  name = var.order_processing_queue_name
}

resource "aws_lambda_permission" "order_processing_lambda_queue_permission" {
  statement_id  = "AllowLambdaOrderProcessingQueue"
  action        = "lambda:InvokeFunction"
  function_name = var.process_orders_function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.update_stocks_queue.arn
}

resource "aws_lambda_permission" "update_stocks_lambda_queue_permission" {
  statement_id  = "AllowLambdaUpdateStocksQueue"
  action        = "lambda:InvokeFunction"
  function_name = var.update_stocks_function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.order_processing_queue_name.arn
}

