module "lambda_strava_upload" {
  source = "./module/python_lambda"

  function_name    = "StravaUpload"
  lambda_bucket_id = aws_s3_bucket.lambda_bucket.id
  memory_size      = 256
  timeout          = 10
}

resource "aws_iam_role_policy_attachment" "lambda_strava_upload_allow_read_write_to_buffer_bucket_policy" {
  role       = module.lambda_strava_upload.aws_iam_role_name
  policy_arn = aws_iam_policy.read_write_to_buffer_bucket.arn
}

resource "aws_iam_role_policy_attachment" "lambda_strava_upload_allow_user_data_read_write_policy" {
  role       = module.lambda_strava_upload.aws_iam_role_name
  policy_arn = aws_iam_policy.allow_user_data_read_write.arn
}

resource "aws_iam_role_policy_attachment" "lambda_strava_upload_allow_allow_app_data_db_read_policy" {
  role       = module.lambda_strava_upload.aws_iam_role_name
  policy_arn = aws_iam_policy.allow_app_data_db_read.arn
}

resource "aws_iam_role_policy_attachment" "lambda_strava_upload_send_to_strava_uploads_queue_policy" {
  role       = module.lambda_strava_upload.aws_iam_role_name
  policy_arn = aws_iam_policy.send_to_strava_uploads_queue.arn
}

resource "aws_s3_bucket_notification" "my-trigger" {
  bucket = aws_s3_bucket.whlsckr_file_buffer_bucket.id

  lambda_function {
    lambda_function_arn = module.lambda_strava_upload.arn
    events              = ["s3:ObjectCreated:*"]
  }
}


