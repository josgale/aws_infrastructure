# Create s3 bucket
resource "aws_s3_bucket" "sa_upload" {
  bucket = var.bucket_name
}

# Set bucket ACL
resource "aws_s3_bucket_acl" "sa_upload_acl" {
  bucket = aws_s3_bucket.sa_upload.id
  acl    = "private"
}