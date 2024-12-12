resource "aws_sqs_queue" "main_queue" {
  name                      = "message-processing-queue"
  message_retention_seconds = 1209600
}
