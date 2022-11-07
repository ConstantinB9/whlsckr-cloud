module "lambda_register_user" {
  source           = "./module/python_lambda"
  memory_size      = 256
  function_name    = "RegisterUser"
  lambda_bucket_id = aws_s3_bucket.lambda_bucket.id
}

resource "aws_iam_role_policy_attachment" "lambda_register_user_allow_app_data_db_read_policy" {
  role       = module.lambda_register_user.aws_iam_role_name
  policy_arn = aws_iam_policy.allow_app_data_db_read.arn
}

resource "aws_iam_role_policy_attachment" "lambda_register_user_allow_user_data_read_write_policy" {
  role       = module.lambda_register_user.aws_iam_role_name
  policy_arn = aws_iam_policy.allow_user_data_read_write.arn
}


resource "aws_apigatewayv2_integration" "register_user" {
  api_id = aws_apigatewayv2_api.whlsckr_api.id

  integration_uri    = module.lambda_register_user.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "register_user_route" {
  api_id = aws_apigatewayv2_api.whlsckr_api.id

  route_key = "ANY /register"
  target    = "integrations/${aws_apigatewayv2_integration.register_user.id}"
}

resource "aws_lambda_permission" "register_user_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_register_user.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.whlsckr_api.execution_arn}/*/*"
}