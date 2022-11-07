
variable "function_name" {
  type        = string
  description = "Name of the Lambda Function"
}

variable "lambda_root_dir" {
  type        = string
  description = "The relative path to the source of the lambda"
  default     = "USE_FUNCTION_NAME"
}


variable "handler" {
  type        = string
  description = "Handler of the Lambda Function"
  default     = "lambda_function.lambda_handler"
}

variable "memory_size" {
  type        = number
  description = "Memory Size allocated in MB"
  default     = 128
}

variable "function_file_name" {
  type        = string
  description = "name of the function .py inside the lamda root directory"
  default     = "lambda_function.py"
}

variable "requirements_file_name" {
  type        = string
  description = "name of the function .py inside the lamda root directory"
  default     = "requirements.txt"
}

variable "lambda_bucket_id" {
  type        = string
  description = "id of the bucket in which the lambda code is uploaded"
}

variable "python_version" {
  type        = string
  description = "Python Version to use"
  default     = "python3.9"
}
