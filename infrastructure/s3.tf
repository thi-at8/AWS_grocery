resource "aws_s3_bucket" "project_bucket" {
  bucket = "aws-grocery-project-bucket-example"

  tags = {
    Name        = "aws-grocery-project-bucket"
    Environment = "documentation"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "project_bucket_block" {
  bucket = aws_s3_bucket.project_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "project_bucket_encryption" {
  bucket = aws_s3_bucket.project_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

