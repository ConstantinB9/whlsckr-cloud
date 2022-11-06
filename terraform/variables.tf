variable "aws_region" {
  description = "AWS region for the resources"

  type    = string
  default = "eu-central-1"
}


variable "lambda_bucket_name" {
  description = "Bucket name where lambda functions are stored"

  type    = string
  default = "whlsckr-lambda-bucket"
}

variable "dropbox_webhook_lambda_root" {
  type        = string
  description = "The relative path to the source of the lambda"
  default     = "../lambda/DropboxWebhook"
}

variable "process_user_update_lambda_root" {
  type        = string
  description = "The relative path to the source of the lambda"
  default     = "../lambda/ProcessUserUpdate"
}
