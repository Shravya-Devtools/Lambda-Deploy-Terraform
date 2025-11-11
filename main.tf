provider "aws" {
  region = "us-east-1"
}

# Use existing IAM Role for Lambda (do NOT create a new one)
data "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_function_name}-role"
}

# IAM Policy Attachment (optional — only if Terraform should attach policy)
# If the role already has AWSLambdaBasicExecutionRole attached, you can remove this block.
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = data.aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_function_name
  s3_bucket     = "mybucket1234567-kiran"
  s3_key        = var.lambda_s3_key
  handler       = "index.handler"
  runtime       = "python3.11"
  role          = data.aws_iam_role.lambda_exec.arn
}

# EventBridge Rule (Schedule)
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.lambda_function_name}-schedule"
  schedule_expression = var.schedule_expression
}

# Permission for EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

# EventBridge Target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.lambda.arn
}
