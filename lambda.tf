resource "aws_lambda_function" "sqs_processor" {
  filename      = "lambda_function.zip"
  function_name = "sqs-message-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 30
  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.main_queue.url
    }
  }
}

resource "aws_cloudwatch_event_rule" "sqs_queue_check" {
  name                = "check-sqs-queue"
  description         = "Triggers every 5m"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "check_sqs_queue" {
  rule      = aws_cloudwatch_event_rule.sqs_queue_check.name
  target_id = "CheckSQSQueue"
  arn       = aws_lambda_function.sqs_processor.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sqs_processor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sqs_queue_check.arn
}
