output "base_url" {
  description = "base url"

  value = aws_apigatewayv2_stage.whlsckr_api_stage.invoke_url
}