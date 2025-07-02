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