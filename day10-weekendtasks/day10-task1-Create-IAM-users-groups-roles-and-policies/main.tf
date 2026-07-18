# iam_groups
resource "aws_iam_group" "usersgroups1" {
  name = "usergroups1"
}

resource "aws_iam_group" "usersgroups2"{
    name = "usergroup2"
}

# users
resource "aws_iam_user" "user1" {
    name = "Vijay"
}

resource "aws_iam_user" "user2" {
    name = "vijju"
}

# Generate Access Keys for testing *****------->Note: Keys will be stored in state file
resource "aws_iam_access_key" "ec2_user_key" {
  user = aws_iam_user.user1.name
}

resource "aws_iam_access_key" "s3_user_key" {
  user = aws_iam_user.user2.name
}

# add users to the groups
resource "aws_iam_user_group_membership" "ec2_user_membership" {
  user = aws_iam_user.user1.name
  groups = [aws_iam_group.usersgroups1.name]
}

resource "aws_iam_user_group_membership" "s3_user_membership" {
  user = aws_iam_user.user2.name
  groups = [aws_iam_group.usersgroups2.name]
}

# policies
resource "aws_iam_policy" "ec2_full_policy" {
  name        = "CustomEC2FullAccess"
  description = "Provides full access to EC2 services"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ec2:*"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "s3_full_policy" {
  name        = "CustomS3FullAccess"
  description = "Provides full access to S3 services"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# policies to the groups

resource "aws_iam_group_policy_attachment" "ec2_attach" {
  group      = aws_iam_group.usersgroups1.name
  policy_arn = aws_iam_policy.ec2_full_policy.arn
}

resource "aws_iam_group_policy_attachment" "s3_attach" {
  group      = aws_iam_group.usersgroups2.name
  policy_arn = aws_iam_policy.s3_full_policy.arn
}

# iam role for ec2-s3

resource "aws_iam_role" "app_role" {
  name = "ec2-s3-access-role"
  
  # Trust policy allowing EC2 instances to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Grant the role full S3 access
resource "aws_iam_role_policy_attachment" "role_s3_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.s3_full_policy.arn
}