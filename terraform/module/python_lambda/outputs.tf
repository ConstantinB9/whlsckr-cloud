output "aws_iam_role_name" {
  description = "Name of the unique Lambda Role"
  value       = aws_iam_role.lambda_function.name
}

output "function_name" {
    value = aws_lambda_function.lambda_function.function_name
}

output "invoke_arn" {
  value = aws_lambda_function.lambda_function.invoke_arn
}

output "arn" {
    value = aws_lambda_function.lambda_function.arn
}