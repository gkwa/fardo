output "lambda_function_name" {
  value = aws_lambda_function.sqs_processor.function_name
}

output "sqs_queue_url" {
  value = aws_sqs_queue.main_queue.url
}
