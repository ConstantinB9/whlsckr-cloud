output "dropbox_webhook_function_name" {
  description = "Name of the dropbox_webhook Lambda function."

  value = aws_lambda_function.dropbox_webhook.function_name
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.whlsckr_api.invoke_url
}