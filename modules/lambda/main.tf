data "aws_iam_policy_document" "lambda_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role" {
  name = "${var.lambda_function_name}-role"

  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid = "1"

    actions = [
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:DescribeInstances",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "${var.lambda_function_name}-policy"
  description = "A policy to allow the lambda start the instances"

  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "policy_attatchment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_lambda_function" "lambda" {
  filename      = var.lambda_code_filename
  function_name = var.lambda_function_name
  role          = aws_iam_role.role.arn
  handler       = var.lambda_code_handler
  timeout = var.timeout

  source_code_hash = var.lambda_code_hash

  runtime = var.runtime
}

resource "aws_cloudwatch_event_rule" "cron" {
  name        = "trigger-${var.lambda_function_name}"
  description = "Call the start lambda function as a cronjob"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.cron.name
  target_id = "trigger-${var.lambda_function_name}-id"
  arn       = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "lambda_perm" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron.arn
}