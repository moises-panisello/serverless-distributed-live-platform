## PROJECT: serverless-distributed-live-platform ##
## Set up the environment * 4 ##
## S3 => S3 Create & configure bucket ##
## Setup S3 bucket ##
## https://github.com/jordicenzano/serverless-distributed-live-platform/blob/master/docs/setup-s3.md ##

resource "aws_s3_bucket" "bucket-media" {
  bucket = local.s3_bucket_name
  acl    = "private"
  lifecycle_rule {
    id      = "delete-older-files-2d"
    enabled = true
    expiration {
      days = 2
    }
    abort_incomplete_multipart_upload_days = 2
  }
  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
  force_destroy = true
  tags = {
    Name = "bucket-media"
  }
}

resource "aws_s3_bucket_public_access_block" "closed-bucket-media" {
  bucket = aws_s3_bucket.bucket-media.id
  block_public_acls        = true
  ignore_public_acls       = true
  block_public_policy      = true
  restrict_public_buckets  = true
}

## PROJECT: serverless-distributed-live-platform ##
## Set up the environment * 8b ##
## Set S3 policy that allow CloudFront to read from
## https://github.com/jordicenzano/serverless-distributed-live-platform/blob/master/docs/setup-cloudfront.md ##

resource "aws_s3_bucket_policy" "bucket-media_policy" {
  bucket = aws_s3_bucket.bucket-media.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "s3:GetObject"
        Resource  = ["${aws_s3_bucket.bucket-media.arn}/*"]
        Principal = { "AWS": aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn }
      }
    ]
  })
  depends_on = [aws_s3_bucket_notification.bucket_notification]
}