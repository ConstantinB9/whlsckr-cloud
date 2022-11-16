resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "whlsckr-terraform"
}

resource "aws_s3_bucket_acl" "terraform_bucket_acl" {
  bucket = aws_s3_bucket.terraform_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "terraform_bucket" {
  bucket = aws_s3_bucket.terraform_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket_name
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "whlsckr_file_buffer_bucket" {
  bucket = "whlsckr-fitfile-buffer"
}

resource "aws_s3_bucket_acl" "file_buffer_bucket_acl" {
  bucket = aws_s3_bucket.whlsckr_file_buffer_bucket.id
  acl    = "private"
}

resource "aws_iam_role" "whlsckr_website_role" {
  name = "WebsiteRole"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "whlsckr_website" {
  bucket = "whlsckr-website"

}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.whlsckr_website.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.whlsckr_website.arn,
      "${aws_s3_bucket.whlsckr_website.arn}/*",
    ]
  }
}
resource "aws_s3_bucket_object" "whlsckr_website_html" {
  for_each     = fileset("../website/", "**/*.html")
  bucket       = aws_s3_bucket.whlsckr_website.id
  key          = each.value
  source       = "../website/${each.value}"
  etag         = filemd5("../website/${each.value}")
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "whlsckr_website_css" {
  for_each     = fileset("../website/", "**/*.css")
  bucket       = aws_s3_bucket.whlsckr_website.id
  key          = each.value
  source       = "../website/${each.value}"
  etag         = filemd5("../website/${each.value}")
  content_type = "text/css"
}

resource "aws_s3_bucket_object" "whlsckr_website_js" {
  for_each     = fileset("../website/", "**/*.js")
  bucket       = aws_s3_bucket.whlsckr_website.id
  key          = each.value
  source       = "../website/${each.value}"
  etag         = filemd5("../website/${each.value}")
  content_type = "application/javascript"
}

resource "aws_s3_bucket_object" "whlsckr_website_svg" {
  for_each     = fileset("../website/", "**/*.svg")
  bucket       = aws_s3_bucket.whlsckr_website.id
  key          = each.value
  source       = "../website/${each.value}"
  etag         = filemd5("../website/${each.value}")
  content_type = "text/svg+xml"
}
