
output "queue1_url" {
  value = aws_sqs_queue.queue1.id
}

output "queue2_url" {
  value = aws_sqs_queue.queue2.id
}