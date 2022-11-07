module "lambda_drobox_webhook" {
  source = "./module/python_lambda"

  function_name    = "DropboxWebhook"
  lambda_bucket_id = aws_s3_bucket.lambda_bucket.id
}

resource "aws_iam_role_policy_attachment" "lambda_dropbox_webhook_allow_app_data_db_read_policy" {
  role       = module.lambda_drobox_webhook.aws_iam_role_name
  policy_arn = aws_iam_policy.allow_app_data_db_read.arn
}

resource "aws_iam_role_policy_attachment" "lambda_dropbox_webhook_allow_invoke_lambda" {
  role       = module.lambda_drobox_webhook.aws_iam_role_name
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
}

resource "aws_apigatewayv2_integration" "dropbox_webhook" {
  api_id = aws_apigatewayv2_api.whlsckr_api.id

  integration_uri    = module.lambda_drobox_webhook.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "dropbox_webhook_route" {
  api_id = aws_apigatewayv2_api.whlsckr_api.id

  route_key = "ANY /dropbox_webhook"
  target    = "integrations/${aws_apigatewayv2_integration.dropbox_webhook.id}"
}

resource "aws_lambda_permission" "drobox_webhook_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_drobox_webhook.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.whlsckr_api.execution_arn}/*/*"
}
