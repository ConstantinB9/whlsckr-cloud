########## DYNAMO DB ##########

resource "aws_dynamodb_table" "user_data" {
  name           = "whlsckr_user_data"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "UserId"


  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "DropboxId"
    type = "S"
  }

  attribute {
    name = "Email"
    type = "S"
  }

  global_secondary_index {
    name               = "DropboxIndex"
    hash_key           = "DropboxId"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId"]
  }

  global_secondary_index {
    name               = "EmailIndex"
    hash_key           = "Email"
    write_capacity     = 1
    read_capacity      = 1
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId"]
  }

  tags = {
    Name        = "whlsckr-user-data"
    Environment = "production"
  }
}

resource "aws_dynamodb_table" "app-credentials" {
  name           = "whlsckr_app_credentials"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "AppName"


  attribute {
    name = "AppName"
    type = "S"
  }

  tags = {
    Name        = "whlsckr-app-data"
    Environment = "production"
  }
}
