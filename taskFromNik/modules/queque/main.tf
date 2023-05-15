resource "aws_sqs_queue" "baevQueue" {
  name = var.queueName
  visibility_timeout_seconds = 300
}

output "queueUrl" {
  value = aws_sqs_queue.baevQueue.url
}

output "queueArn" {
  value = aws_sqs_queue.baevQueue.arn
}