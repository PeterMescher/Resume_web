data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda/crc_website_counter.py"
  output_path = "lambda/crc_website_counter.zip"
}

resource "aws_lambda_function" "crc_website_counter" {
  function_name = "crc_website_counter"
  role          = aws_iam_role.crc_lambda_execution_role.arn
  handler       = "crc_website_counter.lambda_handler"
  runtime       = "python3.11"

  source_code_hash = data.archive_file.lambda.output_base64sha256
  filename         = data.archive_file.lambda.output_path

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.crc_resume_counter_table.name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.crc_lambda_cloudwatch_policy_attachment,
    aws_iam_role_policy_attachment.crc_lambda_dynamodb_policy_attachment,
  ]
}