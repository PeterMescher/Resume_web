resource "aws_dynamodb_table" "crc_resume_counter_table" {
  name           = "crc_resume_counter"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "page_name"
  attribute {
    name = "page_name"
    type = "S"
  }
}