module "lambda_strava_stats_changer" {
  source = "./module/python_lambda"

  function_name    = "StravaStatsChanger"
  lambda_bucket_id = aws_s3_bucket.lambda_bucket.id
  memory_size      = 128
  timeout = 10
}

resource "aws_iam_role_policy_attachment" "lambda_strava_stats_changer_allow_user_data_read_policy" {
  role       = module.lambda_strava_stats_changer.aws_iam_role_name
  policy_arn = aws_iam_policy.allow_user_data_read.arn
}

resource "aws_iam_role_policy_attachment" "lambda_strava_stats_changer_allow_receive_from_strava_uploads_queue_policy" {
  role       = module.lambda_strava_stats_changer.aws_iam_role_name
  policy_arn = aws_iam_policy.receive_from_strava_uploads_queue.arn
}

resource "aws_iam_role_policy_attachment" "lambda_strava_stats_changer_allow_user_data_read_write_policy" {
  role       = module.lambda_strava_stats_changer.aws_iam_role_name
  policy_arn = aws_iam_policy.allow_user_data_read_write.arn
}

resource "aws_lambda_event_source_mapping" "lambda_strava_stats_changer_sqs_event_src" {
  event_source_arn = aws_sqs_queue.strava_uploads.arn
  function_name    = module.lambda_strava_stats_changer.arn
}
