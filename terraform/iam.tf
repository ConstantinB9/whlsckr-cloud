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
  description = "Allow Reading from App Data DB"

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
          "dynamodb:DescribeTimeToLive"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:dynamodb:*:*:table/whlsckr_user_data"
      }
    ]
  })
}