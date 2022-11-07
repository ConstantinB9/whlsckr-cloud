######### API Gateway #########

resource "aws_apigatewayv2_api" "whlsckr_api" {
  name          = "whlsckr_api_gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "whlsckr_api_stage" {
  api_id = aws_apigatewayv2_api.whlsckr_api.id

  name        = "whlsckr"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.whlsckr_api.name}"

  retention_in_days = 30
}