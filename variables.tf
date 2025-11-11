variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "lambda_s3_bucket" {
  description = "S3 bucket where Lambda zip is stored"
  type        = string
}

variable "lambda_s3_key" {
  description = "S3 key of the Lambda zip"
  type        = string
}

variable "schedule_expression" {
  description = "EventBridge schedule expression"
  type        = string
}
