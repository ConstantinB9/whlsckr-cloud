locals {
  root_dir = var.lambda_root_dir != "USE_FUNCTION_NAME" ? var.lambda_root_dir : "../lambda/${var.function_name}"
}

resource "null_resource" "install_dependencies_lambda_function" {
  provisioner "local-exec" {
    command = "pip install -r ${local.root_dir}/${var.requirements_file_name} -t ${local.root_dir}/"
  }

  triggers = {
    dependencies_versions = filemd5("${local.root_dir}/${var.requirements_file_name}")
    source_versions       = filemd5("${local.root_dir}/${var.function_file_name}")
  }
}

resource "random_uuid" "lambda_function_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(local.root_dir, var.function_file_name),
      fileset(local.root_dir, var.requirements_file_name)
    ) :
    filename => filemd5("${local.root_dir}/${filename}")
  }
}


data "archive_file" "lambda_function" {
  depends_on = [null_resource.install_dependencies_lambda_function]
  excludes = [
    "__pycache__",
    ".venv",
  ]

  source_dir  = local.root_dir
  output_path = "${random_uuid.lambda_function_src_hash.result}.zip"
  type        = "zip"
}

resource "aws_s3_object" "lambda_function" {
  bucket = var.lambda_bucket_id

  key    = "${random_uuid.lambda_function_src_hash.result}.zip"
  source = data.archive_file.lambda_function.output_path

  etag = filemd5(data.archive_file.lambda_function.output_path)
}

resource "aws_iam_role" "lambda_function" {
  name = "${var.function_name}Role"

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

resource "aws_iam_role_policy_attachment" "lambda_function" {
  role       = aws_iam_role.lambda_function.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name

  s3_bucket = var.lambda_bucket_id
  s3_key    = aws_s3_object.lambda_function.key

  runtime = "python3.9"
  handler = var.handler

  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  memory_size      = var.memory_size
  timeout = var.timeout

  role = aws_iam_role.lambda_function.arn
}

resource "aws_cloudwatch_log_group" "lambda_function" {
  name = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"

  retention_in_days = 30
}
