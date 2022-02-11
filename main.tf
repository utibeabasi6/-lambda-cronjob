module "start_lambda" {
  source = "./modules/lambda"
  lambda_code_hash = filebase64sha256("zips/start_instances.zip")
  lambda_code_handler = "start.start"
  lambda_function_name = "start_instances"
  lambda_code_filename = "zips/start_instances.zip"
  schedule_expression = "cron(45 23 ? * 1 *)"
}

module "stop_lambda" {
  source = "./modules/lambda"
  lambda_code_hash = filebase64sha256("zips/stop_instances.zip")
  lambda_code_handler = "stop.stop"
  lambda_function_name = "stop_instances"
  lambda_code_filename = "zips/stop_instances.zip"
  schedule_expression = "cron(15 1 ? * 2 *)"
}