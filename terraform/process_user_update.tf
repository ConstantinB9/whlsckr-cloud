module "lambda_process_user_update" {
  source = "./module/python_lambda"

  function_name    = "ProcessUserUpdate"
  lambda_bucket_id = aws_s3_bucket.lambda_bucket.id
  memory_size      = 256
}

resource "aws_iam_role_policy_attachment" "lambda_process_user_update_allow_app_data_db_read_policy" {
  role       = module.lambda_process_user_update.aws_iam_role_name
  policy_arn = aws_iam_policy.allow_app_data_db_read.arn
}

resource "aws_iam_role_policy_attachment" "lambda_process_user_update_allow_user_data_read_write_policy" {
  role       = module.lambda_process_user_update.aws_iam_role_name
  policy_arn = aws_iam_policy.allow_user_data_read_write.arn
}

resource "aws_iam_role_policy_attachment" "lambda_process_user_update_allow_write_to_buffer_bucket_policy" {
  role       = module.lambda_process_user_update.aws_iam_role_name
  policy_arn = aws_iam_policy.write_to_buffer_bucket.arn
}
