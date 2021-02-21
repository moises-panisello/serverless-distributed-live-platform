#!/usr/bin/env bash

# Import variables
source base.sh

# exit when any command fails
set -e

# Create role
echo "Creating role $IAM_LAMBDA_ROLE_CHUNK_TRANSCODER in $AWS_REGION"
aws $AWS_FLAGS_JSON --region $AWS_REGION iam create-role --role-name $IAM_LAMBDA_ROLE_CHUNK_TRANSCODER --assume-role-policy-document file://lambda-role-trust-policy.json

# Add policies to role
echo "Adding policy $IAM_POLICY_S3_FULL_ACCESS to role $IAM_LAMBDA_ROLE_CHUNK_TRANSCODER"
aws $AWS_FLAGS_JSON --region $AWS_REGION iam put-role-policy --role-name $IAM_LAMBDA_ROLE_CHUNK_TRANSCODER --policy-name $IAM_POLICY_S3_FULL_ACCESS --policy-document file://s3-full-access-policy.json

echo "Adding policy $IAM_POLICY_DDB_FULL_ACCESS to role $IAM_LAMBDA_ROLE_CHUNK_TRANSCODER"
aws $AWS_FLAGS_JSON --region $AWS_REGION iam put-role-policy --role-name $IAM_LAMBDA_ROLE_CHUNK_TRANSCODER --policy-name $IAM_POLICY_DDB_FULL_ACCESS --policy-document file://ddb-full-access-policy.json

echo "Adding policy $IAM_POLICY_LAMBDA_LOGS to role $IAM_LAMBDA_ROLE_CHUNK_TRANSCODER"
aws $AWS_FLAGS_JSON --region $AWS_REGION iam put-role-policy --role-name $IAM_LAMBDA_ROLE_CHUNK_TRANSCODER --policy-name $IAM_POLICY_LAMBDA_LOGS --policy-document file://cloudwatch-lambda-policy.json

# Get role ARN
ARN_IAM_LAMBDA_ROLE_CHUNK_TRANSCODER=$(aws $AWS_FLAGS_TEXT iam get-role --role-name $IAM_LAMBDA_ROLE_CHUNK_TRANSCODER --query 'Role.Arn')

echo "Creating lambda $LAMBDA_CHUNK_TRANSCODER_NAME (ARN: $ARN_IAM_LAMBDA_ROLE_CHUNK_TRANSCODER) pointing it to DDB ($DDB_CONFIG_TABLE_NAME, $DDB_CONFIG_TABLE_CHUNKS)"
aws $AWS_FLAGS_JSON --region $AWS_REGION lambda create-function --function-name $LAMBDA_CHUNK_TRANSCODER_NAME --runtime nodejs12.x --handler index.handler --timeout 180 --memory-size 10240 --role $ARN_IAM_LAMBDA_ROLE_CHUNK_TRANSCODER --zip-file "fileb://emptyLambda/index.zip" --environment "Variables={DDB_CONFIG_TABLE_NAME=$DDB_CONFIG_TABLE_NAME,DDB_CONFIG_TABLE_CHUNKS=$DDB_CONFIG_TABLE_CHUNKS}"