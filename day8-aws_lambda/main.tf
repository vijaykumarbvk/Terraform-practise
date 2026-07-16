resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# policy

resource "aws_iam_role_policy_attachment" "lambda_execution_role_policy" {
    role = aws_iam_role.lambda_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "lambda" {
    function_name = "lambda_prac"
    runtime = "python3.14"
    role = aws_iam_role.lambda_execution_role.arn
    handler = "lambda_prac.lambda_handler"
    timeout = 300
    memory_size = 128
    # filename = "lambda_prac.zip"    #replacing the filename with s3 location of the zip file
    s3_bucket = aws_s3_bucket.lambda_bucket.bucket
    s3_key = aws_s3_object.code.key

    source_code_hash = filebase64sha256("lambda_prac.zip")  #It forces Lambda to redeploy when the zip contents change.

    # whenever the lambda function is updated, the zip file will be updated and the lambda function will be updated as well

    #Without source_code_hash, Terraform might not detect when the code in the ZIP file has changed — meaning your Lambda might not update even after uploading a new ZIP.

    #This hash is a checksum that triggers a deployment.

}

resource "aws_cloudwatch_event_rule" "lambda_schedule" {
    name = "lambda_schedule_rule"
    description = "Trigger Lambda every 5 minutes"
    schedule_expression = "cron(0/5 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
    rule = aws_cloudwatch_event_rule.lambda_schedule.name
    target_id = "lambda_target"
    arn = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.lambda_schedule.arn
}

resource "aws_s3_bucket" "lambda_bucket" {
    bucket = "lambda-prac-bucket-vj"
    
}

resource "aws_s3_object" "code" {
    bucket = aws_s3_bucket.lambda_bucket.bucket
    key = "Lambda_prac.zip"
    source = "lambda_prac.zip"
    etag = filemd5("lambda_prac.zip")
}

# etag is used to check if the file has changed. if the file has changed, 
# the etag will change and the s3 object will be updated. if the file has not changed. 
# the etag will not change and the s3 object will not be updated, 
# this is used to avoid unneccessary updates to the s3 object and the lambda function.

# Note:
# always create a zip file of the lambda_prac.py file and upload it to the s3 bucket.
# and make sure delete the zip file while you create a new code and recreate a new zip file and upload it to the s3.