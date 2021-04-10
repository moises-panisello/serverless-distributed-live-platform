## PROJECT: serverless-distributed-live-platform ##
## Set up the environment * 6b ##
## Lambda => Transcode and Manifest Lambdas: Upload codes ##
## Set up Lambdas(create execution roles, lambdas, and upload code) ##
## https://github.com/jordicenzano/serverless-distributed-live-platform/blob/master/docs/setup-lambdas.md ##

resource "aws_lambda_function" "lambda_chunk_transcoder" {
  filename      = "lambda/ChunkTranscoderLambda.zip"
  function_name = local.lambda_chunk_transcoder_name
  role          = aws_iam_role.iam_lambda_role_chunk_transcoder.arn
  handler       = "index.handler"
  timeout       = 180
  memory_size   = 10240
  source_code_hash = filebase64sha256("lambda/ChunkTranscoderLambda.zip")
  runtime = "nodejs12.x"
  environment {
    variables = {
      DDB_CONFIG_TABLE_NAME = local.ddb_config_table_name,
      DDB_CONFIG_TABLE_CHUNKS = local.ddb_chunks_table_name
    }
  }
}

resource "aws_lambda_function" "lambda_manifest" {
  filename      = "lambda/ManifestLambda.zip"
  function_name = local.lambda_manifest_name
  role          = aws_iam_role.iam_lambda_role_manifest.arn
  handler       = "index.handler"
  timeout       = 180
  memory_size   = 10240
  source_code_hash = filebase64sha256("lambda/ManifestLambda.zip")
  runtime = "nodejs12.x"
  environment {
    variables = {
      DDB_CONFIG_TABLE_NAME = local.ddb_config_table_name,
      DDB_CONFIG_TABLE_CHUNKS = local.ddb_chunks_table_name
    }
  }
}

## PROJECT: serverless-distributed-live-platform ##
## Set up the environment * 7 ##
## Lambda => Every time a new file is uploaded (at the end) to /ingest in our S3 media bucket execute a transcode lambda ##
## Set up trigger for lambda transcode ##
## https://github.com/jordicenzano/serverless-distributed-live-platform/blob/master/docs/setup-lambda-transcode-trigger.md ##

resource "aws_lambda_permission" "allow_s3invoke" {
  statement_id  = "s3invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_chunk_transcoder.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket-media.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket-media.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_chunk_transcoder.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "ingest/"
    filter_suffix       = ".ts"
  }
  depends_on = [aws_lambda_permission.allow_s3invoke]
}

## PROJECT: serverless-distributed-live-platform ##
## Set up the environment * 10b ##
## Set up PI Gateway ##
## Grant permissions to API Gateway to call lambdas ##
## https://github.com/jordicenzano/serverless-distributed-live-platform/blob/master/docs/setup-api-gateway.md ##

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "allow_apigateway-to-manifest-lambda" {
  statement_id  = "apigateway-to-manifest-lambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_manifest.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api_gw_rest_api_distributed_transcoding.id}/*/GET/video/*/manifest.m3u8"
}

resource "aws_lambda_permission" "allow_apigateway-to-chunklist-lambda" {
  statement_id  = "apigateway-to-chunklist-lambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_manifest.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api_gw_rest_api_distributed_transcoding.id}/*/GET/video/*/*/chunklist.m3u8"
}
