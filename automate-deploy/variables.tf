variable "aws_region" {
  type = string
  description = "The AWS region where the project will be deployed"
}

variable "base_name" {
  type = string
  description = "Base name of the project that will be deployed"
}

variable "key_name" {
  type = string
  description = "Key name of the Key pair used to SSH into the edge-machine"
}

resource "random_id" "id" {
	  byte_length = 8
}

locals {
  s3_bucket_name = "${var.base_name}-s3-bucket-media-${random_id.id.hex}"

  iam_ec2_role_s3_full_access="${var.base_name}-ec2-role-s3-full-acc"
  iam_ec2_policy_s3_full_access="${var.base_name}-ec2-policy-s3-full-access"
  iam_instance_profile_s3_full_access="${var.base_name}-instance-profile-s3-full-access"

  lambda_chunk_transcoder_name="${var.base_name}-lambda-chunk-transcoder"
  iam_lambda_role_chunk_transcoder="${var.base_name}-role-lambda-chunk-transcoder"
  iam_lambda_chunk_transcoder_policy_s3_full_access="${var.base_name}-lambda-chunk-transcoder-policy-s3-full-access"
  iam_lambda_chunk_transcoder_policy_ddb_full_access="${var.base_name}-lambda-chunk-transcoder-policy-ddb-full-access"
  iam_lambda_chunk_transcoder_policy_cloudwatch_logs="${var.base_name}-lambda-chunk-transcoder-policy-cloudwatch-logs"

  lambda_manifest_name="${var.base_name}-lambda-manifest"
  iam_lambda_role_manifest="${var.base_name}-role-lambda-manifest"
  iam_lambda_manifest_policy_ddb_read_access="${var.base_name}-policy-manifest-ddb-read-access"
  iam_lambda_manifest_policy_cloudwatch_logs="${var.base_name}-policy-manifest-cloudwatch-logs"

  ddb_config_table_name="${var.base_name}-ddb-configs"
  ddb_chunks_table_name="${var.base_name}-ddb-chunks"

  cloudfront_distribution_name="${var.base_name}-cloudfront-media"
  cloudfront_origin_shield_region="eu-west-2" # London (not all regions are available for origin shield)

  aws_apigateway_name="api-live-distributed-platform"
}

output "s3_bucket_name" {
  value       = local.s3_bucket_name
  description = "S3 bucket-media's name."
}
