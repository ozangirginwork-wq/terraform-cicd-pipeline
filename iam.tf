resource "aws_iam_role" "lab5_readonly_role" {
  name = "lab5-readonly-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "lab5-readonly-role"
  }
}

resource "aws_iam_role_policy" "lab5_readonly_policy" {
  name = "lab5-readonly-policy"
  role = aws_iam_role.lab5_readonly_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.secure_data.arn
      },
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.secure_data.arn}/*"
      }
    ]
  })
}