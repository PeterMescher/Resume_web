data "aws_iam_policy_document" "crc_lambda_cloudwatch_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*",
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*",
    ]
  }
}

data "aws_iam_policy_document" "crc_lambda_dynamodb_policy" {
  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.crc_resume_counter_table.name}",
    ]
  }
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "crc_lambda_execution_role" {
  name = "crc_lambda_execution_role"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_policy" "crc_lambda_cloudwatch_policy" {
  name   = "CloudWatchLogsPolicy"
  policy = data.aws_iam_policy_document.crc_lambda_cloudwatch_policy.json
}

resource "aws_iam_policy" "crc_lambda_dynamodb_policy" {
  name   = "DynamoDBPolicy"
  policy = data.aws_iam_policy_document.crc_lambda_dynamodb_policy.json
}

resource "aws_iam_role_policy_attachment" "crc_lambda_cloudwatch_policy_attachment" {
  role       = aws_iam_role.crc_lambda_execution_role.name
  policy_arn = aws_iam_policy.crc_lambda_cloudwatch_policy.arn
}

resource "aws_iam_role_policy_attachment" "crc_lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.crc_lambda_execution_role.name
  policy_arn = aws_iam_policy.crc_lambda_dynamodb_policy.arn
}

