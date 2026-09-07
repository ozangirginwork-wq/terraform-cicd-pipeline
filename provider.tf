provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "Lab5-Secure-AWS-Terraform"
      Environment = "Lab"
      ManagedBy   = "Terraform"
    }
  }
}