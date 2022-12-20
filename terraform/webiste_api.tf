module "lambda_website_api" {
  source = "./module/python_lambda"

  function_name    = "website-api"
  lambda_bucket_id = aws_s3_bucket.lambda_bucket.id
  memory_size      = 128
  timeout          = 3
}

resource "aws_iam_role_policy_attachment" "lambda_website_api_allow_user_data_read_policy" {
  role       = module.lambda_website_api.aws_iam_role_name
  policy_arn = aws_iam_policy.allow_user_data_read.arn
}

resource "aws_iam_role_policy_attachment" "lambda_website_api_allow_app_data_db_read_policy" {
  role       = module.lambda_website_api.aws_iam_role_name
  policy_arn = aws_iam_policy.allow_app_data_db_read.arn
}

resource "aws_apigatewayv2_integration" "website_api" {
  api_id = aws_apigatewayv2_api.whlsckr_website_api.id

  integration_uri    = module.lambda_website_api.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "website_api_route" {
  api_id = aws_apigatewayv2_api.whlsckr_website_api.id

  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.website_api.id}"
}

resource "aws_lambda_permission" "website_api_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_website_api.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.whlsckr_website_api.execution_arn}/*/*"
}
