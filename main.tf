resource "aws_iam_role" "start_role" {
  name = "start_role"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
    "Action": "sts:AssumeRole",
    "Principal": {
        "Service": "lambda.amazonaws.com"
        },
    "Effect": "Allow",
    "Sid": ""
    }
]
}
EOF
}

resource "aws_iam_role" "stop_role" {
  name = "stop_role"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
    "Action": "sts:AssumeRole",
    "Principal": {
        "Service": "lambda.amazonaws.com"
        },
    "Effect": "Allow",
    "Sid": ""
    }
]
}
EOF
}

resource "aws_iam_policy" "start_policy" {
  name        = "start_policy"
  description = "A policy to allow the lambda start the instances"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:StartInstances",
        "ec2:DescribeInstances",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "stop_policy" {
  name        = "stop_policy"
  description = "A policy to allow the lambda stop the instances"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:StopInstances",
        "ec2:DescribeInstances",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "start_attach" {
  role       = aws_iam_role.start_role.name
  policy_arn = aws_iam_policy.start_policy.arn
}

resource "aws_iam_role_policy_attachment" "stop_attach" {
  role       = aws_iam_role.stop_role.name
  policy_arn = aws_iam_policy.stop_policy.arn
}

resource "aws_lambda_function" "start_instances" {
  filename      = "zips/start_instances.zip"
  function_name = "start_instances"
  role          = aws_iam_role.start_role.arn
  handler       = "start.start"
  timeout = 100

  source_code_hash = filebase64sha256("zips/start_instances.zip")

  runtime = "python3.9"
}

resource "aws_lambda_function" "stop_instances" {
  filename      = "zips/stop_instances.zip"
  function_name = "stop_instances"
  role          = aws_iam_role.stop_role.arn
  handler       = "stop.stop"
  timeout = 100

  source_code_hash = filebase64sha256("zips/stop_instances.zip")

  runtime = "python3.9"

}

resource "aws_cloudwatch_event_rule" "start_cron" {
  name        = "trigger-start-lambda"
  description = "Call the start lambda function as a cronjob"
  schedule_expression = "cron(45 1 * * SUN *)"
}

resource "aws_cloudwatch_event_rule" "stop_cron" {
  name        = "trigger-stop-lambda"
  description = "Call the stop lambda function as a cronjob"
  schedule_expression = "cron(30 23 * * SUN *)"
}

resource "aws_cloudwatch_event_target" "start_lambda" {
  rule      = aws_cloudwatch_event_rule.start_cron.name
  target_id = "TriggerStartLambda"
  arn       = aws_lambda_function.start_instances.arn
}

resource "aws_cloudwatch_event_target" "stop_lambda" {
  rule      = aws_cloudwatch_event_rule.stop_cron.name
  target_id = "TriggerStopLambda"
  arn       = aws_lambda_function.stop_instances.arn
}

resource "aws_lambda_permission" "allow_start" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_instances.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_cron.arn
}

resource "aws_lambda_permission" "allow_stop" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_instances.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_cron.arn
}