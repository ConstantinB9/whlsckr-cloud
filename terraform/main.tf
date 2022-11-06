terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

######### General #########

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket_name
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

######### LAMBDA FUNCTIONS #########

# DropboxWebhook

resource "null_resource" "install_dependencies_dropbox_webhook" {
  provisioner "local-exec" {
    command = "pip install -r ${var.dropbox_webhook_lambda_root}/requirements.txt -t ${var.dropbox_webhook_lambda_root}/"
  }

  triggers = {
    dependencies_versions = filemd5("${var.dropbox_webhook_lambda_root}/requirements.txt")
    source_versions       = filemd5("${var.dropbox_webhook_lambda_root}/lambda_function.py")
  }
}

resource "random_uuid" "dropbox_webhook_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(var.dropbox_webhook_lambda_root, "lambda_function.py"),
      fileset(var.dropbox_webhook_lambda_root, "requirements.txt")
    ) :
    filename => filemd5("${var.dropbox_webhook_lambda_root}/${filename}")
  }
}


data "archive_file" "lambda_dropbox_webhook" {
  depends_on = [null_resource.install_dependencies_dropbox_webhook]
  excludes = [
    "__pycache__",
    ".venv",
  ]

  source_dir  = var.dropbox_webhook_lambda_root
  output_path = "${random_uuid.dropbox_webhook_src_hash.result}.zip"
  type        = "zip"
}

resource "aws_s3_object" "lambda_dropbox_webhook" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "${random_uuid.dropbox_webhook_src_hash.result}.zip"
  source = data.archive_file.lambda_dropbox_webhook.output_path

  etag = filemd5(data.archive_file.lambda_dropbox_webhook.output_path)
}

resource "aws_lambda_function" "dropbox_webhook" {
  function_name = "DropboxWebhook"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_dropbox_webhook.key

  runtime = "python3.9"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_dropbox_webhook.output_base64sha256
  memory_size      = 128

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "dropbox_webhook" {
  name = "/aws/lambda/${aws_lambda_function.dropbox_webhook.function_name}"

  retention_in_days = 30
}


# ProcessUserUpdate

resource "null_resource" "install_dependencies_process_user_update" {
  provisioner "local-exec" {
    command = "pip install -r ${var.process_user_update_lambda_root}/requirements.txt -t ${var.process_user_update_lambda_root}/"
  }

  triggers = {
    dependencies_versions = filemd5("${var.process_user_update_lambda_root}/requirements.txt")
    source_versions       = filemd5("${var.process_user_update_lambda_root}/lambda_function.py")
  }
}

resource "random_uuid" "process_user_update_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(var.process_user_update_lambda_root, "lambda_function.py"),
      fileset(var.process_user_update_lambda_root, "requirements.txt")
    ) :
    filename => filemd5("${var.process_user_update_lambda_root}/${filename}")
  }
}


data "archive_file" "lambda_process_user_update" {
  depends_on = [null_resource.install_dependencies_process_user_update]
  excludes = [
    "__pycache__",
    ".venv",
  ]

  source_dir  = var.process_user_update_lambda_root
  output_path = "${random_uuid.process_user_update_src_hash.result}.zip"
  type        = "zip"
}

resource "aws_s3_object" "lambda_process_user_update" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "${random_uuid.process_user_update_src_hash.result}.zip"
  source = data.archive_file.lambda_process_user_update.output_path

  etag = filemd5(data.archive_file.lambda_process_user_update.output_path)
}

resource "aws_lambda_function" "process_user_update" {
  function_name = "ProcessUserUpdate"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_process_user_update.key

  runtime = "python3.9"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_process_user_update.output_base64sha256
  memory_size      = 256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "process_user_update" {
  name = "/aws/lambda/${aws_lambda_function.process_user_update.function_name}"

  retention_in_days = 30
}




######### IAM Setup #########


resource "aws_iam_role" "lambda_exec" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_invoke_policy" {
  name        = "AllowLambdaInvoke"
  description = "Allow invoking of a Lambda function"

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:InvokeFunction",
        "lambda:InvokeAsync"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
})
}

resource "aws_iam_role_policy_attachment" "lambda_invoke_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
}


######### API Gateway #########


resource "aws_apigatewayv2_api" "whlsckr_api" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "whlsckr_api" {
  api_id = aws_apigatewayv2_api.whlsckr_api.id

  name        = "serverless_lambda_stage"
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

resource "aws_apigatewayv2_integration" "dropbox_webhook" {
  api_id = aws_apigatewayv2_api.whlsckr_api.id

  integration_uri    = aws_lambda_function.dropbox_webhook.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "dropbox_webhook" {
  api_id = aws_apigatewayv2_api.whlsckr_api.id

  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.dropbox_webhook.id}"
}


resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.whlsckr_api.name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dropbox_webhook.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.whlsckr_api.execution_arn}/*/*"
}
