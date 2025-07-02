resource "aws_dynamodb_table" "crc_resume_counter_table" {
  name           = "crc_resume_counter"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "page_name"
  attribute {
    name = "page_name"
    type = "S"
  }
}

data "aws_iam_policy_document" "crc_lambda_dynamodb_resource_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.crc_lambda_execution_role.name}"]
    }
    effect    = "Allow"
    sid       = "AllowLambdaDynamoDBAccess"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
    ]
    resources = [
      aws_dynamodb_table.crc_resume_counter_table.arn,
    ]
  }

}

resource "aws_dynamodb_resource_policy" "crc_resume_counter_policy" {
  resource_arn = aws_dynamodb_table.crc_resume_counter_table.arn
  policy       = data.aws_iam_policy_document.crc_lambda_dynamodb_resource_policy.json
}