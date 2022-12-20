module "lambda_get_user_data" {
  source = "./module/python_lambda"

  function_name    = "GetUserData"
  lambda_bucket_id = aws_s3_bucket.lambda_bucket.id
}

resource "aws_iam_role_policy_attachment" "lambda_get_user_data_allow_app_data_db_read_policy" {
  role       = module.lambda_get_user_data.aws_iam_role_name
  policy_arn = aws_iam_policy.allow_app_data_db_read.arn
}

resource "aws_iam_role_policy_attachment" "lambda_get_user_data_allow_user_data_read_write_policy" {
  role       = module.lambda_get_user_data.aws_iam_role_name
  policy_arn = aws_iam_policy.allow_user_data_read.arn
}

resource "aws_iam_role_policy_attachment" "lambda_get_user_data_allow_invoke_lambda" {
  role       = module.lambda_get_user_data.aws_iam_role_name
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
}

resource "aws_apigatewayv2_integration" "get_user_data" {
  api_id = aws_apigatewayv2_api.whlsckr_api.id

  integration_uri    = module.lambda_get_user_data.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "get_user_data_route" {
  api_id = aws_apigatewayv2_api.whlsckr_api.id

  route_key = "ANY /user_data"
  target    = "integrations/${aws_apigatewayv2_integration.get_user_data.id}"
}

resource "aws_lambda_permission" "user_data_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_get_user_data.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.whlsckr_api.execution_arn}/*/*"
}
