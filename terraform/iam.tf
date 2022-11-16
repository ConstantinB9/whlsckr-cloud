######### IAM Setup #########

# Policies
resource "aws_iam_policy" "lambda_invoke_policy" {
  name        = "AllowLambdaInvoke"
  description = "Allow invoking of a Lambda function"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "lambda:InvokeFunction",
          "lambda:InvokeAsync"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "allow_app_data_db_read" {
  name        = "AllowDynamodbRead"
  description = "Allow Reading from App Data DB"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "dynamodb:GetItem",
          "dynamodb:List*",
          "dynamodb:DescribeReservedCapacity*",
          "dynamodb:DescribeLimits",
          "dynamodb:DescribeTimeToLive"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:dynamodb:*:*:table/whlsckr_app_credentials"
      }
    ]
  })
}

resource "aws_iam_policy" "allow_user_data_read_write" {
  name        = "AllowDynamodbReadWrite"
  description = "Allow Reading from User Data DB"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:List*",
          "dynamodb:DescribeReservedCapacity*",
          "dynamodb:DescribeLimits",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:Query",
          "dynamodb:*"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:dynamodb:*:*:table/whlsckr_user_data*"
      }
    ]
  })
}
resource "aws_iam_policy" "allow_user_data_read" {
  name        = "AllowUserDataRead"
  description = "Allow Reading from User Data DB"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "dynamodb:GetItem",
          "dynamodb:List*",
          "dynamodb:DescribeReservedCapacity*",
          "dynamodb:DescribeLimits",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:Query",
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:dynamodb:*:*:table/whlsckr_user_data*"
      }
    ]
  })
}

resource "aws_iam_policy" "write_to_buffer_bucket" {
  name        = "AllowWriteBufferBucket"
  description = "Allow Writing to whlsckr-fitfile-buffer"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:PutObject"
        ],
        "Effect" : "Allow",
        "Resource" : "${aws_s3_bucket.whlsckr_file_buffer_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_policy" "read_write_to_buffer_bucket" {
  name        = "AllowWriteReadBufferBucket"
  description = "Allow Writing to whlsckr-fitfile-buffer"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "receive_from_strava_uploads_queue" {
  name        = "AllowReadStravaUploadsQueue"
  description = "Allow Reading from whlsckr-strava-uploads SQS Queue"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        "Effect" : "Allow",
        "Resource" : aws_sqs_queue.strava_uploads.arn
      }
    ]
  })
}
resource "aws_iam_policy" "send_to_strava_uploads_queue" {
  name        = "AllowWriterStravaUploadsQueue"
  description = "Allow Writing to whlsckr-strava-uploads SQS Queue"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "sqs:SendMessage",
        ],
        "Effect" : "Allow",
        "Resource" : aws_sqs_queue.strava_uploads.arn
      }
    ]
  })
}

data "aws_iam_policy_document" "website_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [
      "*"
    ]
  }
}
