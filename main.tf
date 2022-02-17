data "archive_file" "lambda_start_function" {
  type             = "zip"
  source_file      = "functions/start.py"
  output_file_mode = "0666"
  output_path      = "zips/start_instances.zip"
}

data "archive_file" "lambda_stop_function" {
  type             = "zip"
  source_file      = "functions/stop.py"
  output_file_mode = "0666"
  output_path      = "zips/stop_instances.zip"
}

module "start_lambda" {
  source = "./modules/lambda"
  lambda_code_hash = data.archive_file.lambda_start_function.output_base64sha256
  lambda_code_handler = "start.start"
  lambda_function_name = "start_instances"
  lambda_code_filename = data.archive_file.lambda_start_function.output_path
  schedule_expression = "cron(45 23 ? * 1 *)"
}

module "stop_lambda" {
  source = "./modules/lambda"
  lambda_code_hash = data.archive_file.lambda_stop_function.output_base64sha256
  lambda_code_handler = "stop.stop"
  lambda_function_name = "stop_instances"
  lambda_code_filename = data.archive_file.lambda_stop_function.output_path
  schedule_expression = "cron(15 1 ? * 2 *)"
}