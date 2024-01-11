
provider "aws" {
  region= var.region
}

resource "random_pet" "lambda_s3_bucket_name"{
  prefix = "udacity-bucket"
  length = 3
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_s3_bucket_name.id
}

resource "aws_s3_bucket_ownership_controls" "lambda_bucket"{
  bucket = aws_s3_bucket.lambda_bucket.id
  rule{
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "lambda_bucket"{
  depends_on = [aws_s3_bucket_ownership_controls.lambda_bucket]

  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}


data "archive_file" "lambda_greeting" {
  type = "zip"

  source_file  = "${path.module}/greet_lambda.py"
  output_path = "${path.module}/greet_lambda.zip"
}

resource "aws_s3_object" "lambda_greeting" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "greet_lambda.zip"
  source = data.archive_file.lambda_greeting.output_path

  etag = filemd5(data.archive_file.lambda_greeting.output_path)
}

#define lambda function and runtime
resource "aws_lambda_function" "greet_lambda"{
  function_name = "LambdaGreeting"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key = aws_s3_object.lambda_greeting.key

  runtime = "python3.8"
  handler = "greet_lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda_greeting.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      greeting = "Bonjour"
    }
  }
}

#define IAM role for executing the lambda function
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }
    ]
  })
}

resource "aws_cloudwatch_log_group" "hello_world" {
  name = "/aws/lambda/${aws_lambda_function.greet_lambda.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
