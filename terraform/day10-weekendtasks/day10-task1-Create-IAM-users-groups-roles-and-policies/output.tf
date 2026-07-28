output "ec2_user_access_key" {
  value = aws_iam_access_key.ec2_user_key.id
}
output "ec2_user_secret_key" {
  value     = aws_iam_access_key.ec2_user_key.secret
  sensitive = true
}

output "s3_user_access_key" {
  value = aws_iam_access_key.s3_user_key.id
}
output "s3_user_secret_key" {
  value     = aws_iam_access_key.s3_user_key.secret
  sensitive = true
}