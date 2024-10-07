variable "JAR_PATH" {
  type    = string
  default = "target/demo-0.0.1-SNAPSHOT-aws.jar"
}

variable "STAGE" {
  type    = string
  default = "local"
}

variable "AWS_REGION" {
  type    = string
  default = "us-east-1"
}

# checking if deploy is for localstack or an actual environment
data "aws_caller_identity" "current" {}
output "is_localstack" {
  value = data.aws_caller_identity.current.id == "000000000000"
}

provider "aws" {
  access_key                  = "test_access_key"
  secret_key                  = "test_secret_key"
  region                      = var.AWS_REGION
  skip_credentials_validation = true
  skip_metadata_api_check     = true

  endpoints {
    apigateway       = var.STAGE == "local" ? "http://localhost:4566" : null
    cloudformation   = var.STAGE == "local" ? "http://localhost:4566" : null
    cloudwatch       = var.STAGE == "local" ? "http://localhost:4566" : null
    cloudwatchevents = var.STAGE == "local" ? "http://localhost:4566" : null
    iam              = var.STAGE == "local" ? "http://localhost:4566" : null
    lambda           = var.STAGE == "local" ? "http://localhost:4566" : null
    s3               = var.STAGE == "local" ? "http://localhost:4566" : null
  }
}

resource "aws_iam_role" "lambda-execution-role" {
  name = "lambda-execution-role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_lambda_function" "helloWorld" {
  filename      = var.JAR_PATH
  function_name = "helloWorld"
  role          = aws_iam_role.lambda-execution-role.arn
  handler       = "org.springframework.cloud.function.adapter.aws.FunctionInvoker::handleRequest"
  runtime       = "java17"
  timeout       = 30
  source_code_hash = filebase64sha256(var.JAR_PATH)
}

resource "aws_lambda_function_url" "hello_world" {
  function_name      = "helloWorld"
  authorization_type = "NONE"
}

output "function_url" {
  description = "Function URL."
  value       = aws_lambda_function_url.hello_world.function_url
}