
resource "aws_sqs_queue" "update_stocks_queue" {
  name = var.update_stocks_queue_name
}

resource "aws_sqs_queue" "order_processing_queue" {
  name = var.order_processing_queue_name
}

