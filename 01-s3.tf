resource "aws_s3_bucket" "s3_bucket" {
  bucket = "youngyz-terraform-bucket-16334"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}