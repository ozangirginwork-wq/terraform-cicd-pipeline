resource "aws_vpc" "lab5_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "lab5-secure-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab5_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "lab5-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.lab5_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "lab5-private-subnet"
  }
}

resource "aws_internet_gateway" "lab5_igw" {
  vpc_id = aws_vpc.lab5_vpc.id

  tags = {
    Name = "lab5-internet-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab5_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab5_igw.id
  }

  tags = {
    Name = "lab5-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.lab5_vpc.id

  ingress = []
  egress  = []

  tags = {
    Name = "lab5-default-sg-restricted"
  }
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/lab5-flow-logs"
  retention_in_days = 365

  tags = {
    Name = "lab5-vpc-flow-logs"
  }
}

# IAM role assumed by the VPC Flow Logs service
resource "aws_iam_role" "vpc_flow_logs" {
  name = "lab5-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "lab5-vpc-flow-logs-role"
  }
}

# Least-privilege permissions for writing VPC Flow Logs to CloudWatch
resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "lab5-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
      }
    ]
  })
}

# Capture accepted and rejected VPC traffic
resource "aws_flow_log" "lab5_vpc" {
  vpc_id                   = aws_vpc.lab5_vpc.id
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn             = aws_iam_role.vpc_flow_logs.arn
  max_aggregation_interval = 60

  tags = {
    Name = "lab5-vpc-flow-log"
  }
}