variable "lambda_code_hash" {
    type = string
    description = "The base64 hash of the lambda source code"
}

variable "lambda_code_handler" {
    type = string
    description = "The entry point to your lambda code"
}

variable "lambda_function_name" {
  type = string
  description = "The name of the lambda function"
}

variable "lambda_code_filename" {
    type = string
    description = "The filename for the lambda function code"
}

variable "schedule_expression" {
    type = string
    description = "The cron expression for the event rule"
}

variable "runtime" {
    type = string
    description = "The runtime for the lambda function"
    default = "python3.9"
}

variable "timeout" {
    type = number
    description = "Timeout for the lambda function's execution"
    default = 100
}