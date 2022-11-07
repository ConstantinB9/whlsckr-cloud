module "lambda_process_user_update" {
  source = "./module/python_lambda"
  
  function_name    = "ProcessUserUpdate"
  lambda_bucket_id = aws_s3_bucket.lambda_bucket.id
}

resource "aws_iam_role_policy_attachment" "lambda_process_user_update_allow_app_data_db_read_policy" {
  role       = module.lambda_process_user_update.aws_iam_role_name
  policy_arn = aws_iam_policy.allow_app_data_db_read.arn
}
