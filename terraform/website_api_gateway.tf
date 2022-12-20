######### API Gateway #########

resource "aws_apigatewayv2_api" "whlsckr_website_api" {
  name          = "whlsckr_website_api_gateway"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"] # todo: update!!! 
    allow_methods = ["POST", "GET", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 300
  }
}

resource "aws_cloudwatch_log_group" "website_api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.whlsckr_website_api.name}"
  retention_in_days = 1
}


resource "aws_apigatewayv2_stage" "whlsckr_website_api_stage" {
  api_id = aws_apigatewayv2_api.whlsckr_website_api.id

  name        = "whlsckr_website"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.website_api_gw.arn

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

