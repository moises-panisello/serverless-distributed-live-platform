## PROJECT: serverless-distributed-live-platform ##
## Set up the environment * 8a ##
## Create CloudFront global CDN layer on top of S3 ##
## Set CloudFront as media CDN ##
## https://github.com/jordicenzano/serverless-distributed-live-platform/blob/master/docs/setup-cloudfront.md ##

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Access to media through CloudFront"
}

resource "aws_cloudfront_cache_policy" "HLS_and_QS_cloudfront_cache_policy" {
  name        = "lde-HLS-ALL-QS"
  comment     = "HLS, uses path + QS for cache key"
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "all"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip = true
  }
}

resource "aws_cloudfront_origin_request_policy" "CORS_request_policy" {
  name    = "lde-S3Origin"
  comment = "Policy for S3 origin with CORS"
  cookies_config {
    cookie_behavior = "none"
  }
  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["origin", "access-control-request-headers", "access-control-request-method"]
    }
  }
  query_strings_config {
    query_string_behavior = "none"
  }
}

locals {
  s3_origin_id = "S3-MediaOutput"
}

## KEEP IN MIND ##
## We couldn't add these properties: 'ConnectionAttempts', 'ConnectionTimeout' and 'OriginShield'
##  because these argument aren't available in an aws_cloudfront_distribution Terraform resource
## https://github.com/hashicorp/terraform-provider-aws/issues/16009
## https://github.com/hashicorp/terraform-provider-aws/issues/15752

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.bucket-media.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
    }
    origin_path              = "/output"
  }
  enabled                    = true
  is_ipv6_enabled            = true
  http_version               = "http2"
  comment                    = "var.base_name"
  default_cache_behavior {
    target_origin_id         = local.s3_origin_id
    allowed_methods          = ["HEAD", "GET", "OPTIONS"]
    cached_methods           = ["HEAD", "GET", "OPTIONS"]
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = aws_cloudfront_cache_policy.HLS_and_QS_cloudfront_cache_policy.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.CORS_request_policy.id
  }
  price_class                = "PriceClass_All"
  restrictions {
    geo_restriction {
      restriction_type       = "none"
    }
  }
  tags = {
    Name                     = "local.cloudfront_distribution_name"
  }
  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}

output "aws_cloudfront_distribution_domain_name" {
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
  description = "Cloudfront Distribution's Domain Name."
}
