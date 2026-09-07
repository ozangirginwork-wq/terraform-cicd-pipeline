resource "aws_security_group" "lab5_secure_sg" {
  name        = "lab5-secure-sg"
  description = "Security group with no inbound access by default"
  vpc_id      = aws_vpc.lab5_vpc.id

  egress {
    description = "Allow outbound HTTPS only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab5-secure-sg"
  }
}