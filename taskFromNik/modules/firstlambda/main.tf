resource "aws_iam_role" "first_lambda_role" {
  name = "first_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "first_lambda_policy" {
  name   = "first_lambda_policy"
  role   = aws_iam_role.first_lambda_role.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": "sqs:*",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": "cloudwatch:*",
        "Resource": "*"
      }
    ]
  })
}

data "archive_file" "zipPythonCode" {
    type = "zip"
    source_dir  = "${path.module}/pythonCode/"
    output_path = "${path.module}/pythonCode/lambda_function.zip"
}

resource "aws_lambda_layer_version" "baev_layer" {
  compatible_architectures = ["x86_64"]
  compatible_runtimes = ["python3.10"]
  layer_name         = "baevLayer"
  s3_bucket          = "bucket-for-nik-task-convertor-mp4-to-mp3"
  s3_key             = "package/mypackage.zip"
}

resource "aws_lambda_function" "s3_lambda" {
  function_name    = "s3_lambda"
  role             = aws_iam_role.first_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  source_code_hash = base64sha256(data.archive_file.zipPythonCode.output_path)
  filename         = data.archive_file.zipPythonCode.output_path
  timeout          = 300
  layers           = [aws_lambda_layer_version.baev_layer.arn]
}

#resource "aws_s3_bucket_notification" "s3_notification" {
#  bucket = var.bucketName
#  depends_on = [aws_lambda_permission.s3_lambda_permission1]
#
#  lambda_function {
#   lambda_function_arn = aws_lambda_function.s3_lambda.arn
#    events              = ["s3:ObjectCreated:*"]
#    filter_prefix       = var.prefix1
#  }
#}

resource "aws_lambda_permission" "s3_lambda_permission1" {
  statement_id  = "AllowExecutionFromS3_1"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}

output "awslambdafunc1" {
 value = aws_lambda_function.s3_lambda.arn
}