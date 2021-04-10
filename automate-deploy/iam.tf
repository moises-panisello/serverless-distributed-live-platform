## PROJECT: serverless-distributed-live-platform ##
## Set up the environment * 2 ##
## IAM => laptop-user user creation ##
## Set permissions to local AWS CLI user ##
## https://github.com/jordicenzano/serverless-distributed-live-platform/blob/master/docs/local-aws-cli-user-permissions.md ##

resource "aws_iam_user" "laptop-user" {
  name = "laptop-user"
  tags = {
    Name = "laptop-user"
  }
}

resource "aws_iam_user_policy_attachment" "AmazonEC2FullAccess" {
  user       = aws_iam_user.laptop-user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user_policy_attachment" "IAMFullAccess" {
  user       = aws_iam_user.laptop-user.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_user_policy_attachment" "AmazonS3FullAccess" {
  user       = aws_iam_user.laptop-user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_policy_attachment" "AmazonDynamoDBFullAccess" {
  user       = aws_iam_user.laptop-user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_user_policy_attachment" "CloudFrontFullAccess" {
  user       = aws_iam_user.laptop-user.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

resource "aws_iam_user_policy_attachment" "AmazonAPIGatewayAdministrator" {
  user       = aws_iam_user.laptop-user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}

resource "aws_iam_user_policy_attachment" "AWSLambda_FullAccess" {
  user       = aws_iam_user.laptop-user.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_access_key" "laptop-user_access_key" {
  user    = aws_iam_user.laptop-user.name
}

output "laptop-user_access_key_id" {
  value       = aws_iam_access_key.laptop-user_access_key.id
  description = "laptop-user's Access key ID."
}

output "laptop-user_secret_access_key" {
  value       = aws_iam_access_key.laptop-user_access_key.secret
  description = "laptop-user's Secret Access Key."
}

## PROJECT: serverless-distributed-live-platform ##
## Set up the environment * 5 ##
## S3 => S3, create role ant attach to EC2 ##
## Give EC2 RW permissions to your S3 ##
## https://github.com/jordicenzano/serverless-distributed-live-platform/blob/master/scripts/create-s3-full-access-for-ec2.sh ##

resource "aws_iam_role" "ec2-role-s3-full-access" {
  name = local.iam_ec2_role_s3_full_access
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "local.iam_ec2_role_s3_full_access"
  }
}

resource "aws_iam_role_policy" "ec2-policy-s3-full-access" {
  name = local.iam_ec2_policy_s3_full_access
  role = aws_iam_role.ec2-role-s3-full-access.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = "s3:*"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_instance_profile" "instance-profile-s3-full-access" {
  name = local.iam_instance_profile_s3_full_access
  role = aws_iam_role.ec2-role-s3-full-access.name
  tags = {
    Name = "local.iam_instance_profile_s3_full_access"
  }
}

## PROJECT: serverless-distributed-live-platform ##
## Set up the environment * 6a ##
## Lambda => Transcode and Manifest Lambdas: create execution roles, execution policies (permissions), attach permissions to roles ##
## Set up Lambdas (create execution roles, lambdas, and upload code) ##
## https://github.com/jordicenzano/serverless-distributed-live-platform/blob/master/docs/setup-lambdas.md ##

resource "aws_iam_role" "iam_lambda_role_chunk_transcoder" {
  name = local.iam_lambda_role_chunk_transcoder
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "local.iam_lambda_role_chunk_transcoder"
  }
}

resource "aws_iam_role_policy" "lambda-chunk-transcoder-policy-s3-full-access" {
  name = local.iam_lambda_chunk_transcoder_policy_s3_full_access
  role = aws_iam_role.iam_lambda_role_chunk_transcoder.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = "s3:*"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda-chunk-transcoder-policy-ddb-full-access" {
  name = local.iam_lambda_chunk_transcoder_policy_ddb_full_access
  role = aws_iam_role.iam_lambda_role_chunk_transcoder.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "dynamodb:*",
                "dax:*",
                "application-autoscaling:DeleteScalingPolicy",
                "application-autoscaling:DeregisterScalableTarget",
                "application-autoscaling:DescribeScalableTargets",
                "application-autoscaling:DescribeScalingActivities",
                "application-autoscaling:DescribeScalingPolicies",
                "application-autoscaling:PutScalingPolicy",
                "application-autoscaling:RegisterScalableTarget",
                "cloudwatch:DeleteAlarms",
                "cloudwatch:DescribeAlarmHistory",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DescribeAlarmsForMetric",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:GetMetricData",
                "datapipeline:ActivatePipeline",
                "datapipeline:CreatePipeline",
                "datapipeline:DeletePipeline",
                "datapipeline:DescribeObjects",
                "datapipeline:DescribePipelines",
                "datapipeline:GetPipelineDefinition",
                "datapipeline:ListPipelines",
                "datapipeline:PutPipelineDefinition",
                "datapipeline:QueryObjects",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "iam:GetRole",
                "iam:ListRoles",
                "kms:DescribeKey",
                "kms:ListAliases",
                "sns:CreateTopic",
                "sns:DeleteTopic",
                "sns:ListSubscriptions",
                "sns:ListSubscriptionsByTopic",
                "sns:ListTopics",
                "sns:Subscribe",
                "sns:Unsubscribe",
                "sns:SetTopicAttributes",
                "lambda:CreateFunction",
                "lambda:ListFunctions",
                "lambda:ListEventSourceMappings",
                "lambda:CreateEventSourceMapping",
                "lambda:DeleteEventSourceMapping",
                "lambda:GetFunctionConfiguration",
                "lambda:DeleteFunction",
                "resource-groups:ListGroups",
                "resource-groups:ListGroupResources",
                "resource-groups:GetGroup",
                "resource-groups:GetGroupQuery",
                "resource-groups:DeleteGroup",
                "resource-groups:CreateGroup",
                "tag:GetResources",
                "kinesis:ListStreams",
                "kinesis:DescribeStream",
                "kinesis:DescribeStreamSummary"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": "cloudwatch:GetInsightRuleReport",
            "Effect": "Allow",
            "Resource": "arn:aws:cloudwatch:*:*:insight-rule/DynamoDBContributorInsights*"
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": [
                        "application-autoscaling.amazonaws.com",
                        "application-autoscaling.amazonaws.com.cn",
                        "dax.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "replication.dynamodb.amazonaws.com",
                        "dax.amazonaws.com",
                        "dynamodb.application-autoscaling.amazonaws.com",
                        "contributorinsights.dynamodb.amazonaws.com",
                        "kinesisreplication.dynamodb.amazonaws.com"
                    ]
                }
            }
        }
    ]
  })
}

resource "aws_iam_role_policy" "lambda-chunk-transcoder-policy-cloudwatch-logs" {
  name = local.iam_lambda_chunk_transcoder_policy_cloudwatch_logs
  role = aws_iam_role.iam_lambda_role_chunk_transcoder.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
  })
}

resource "aws_iam_role" "iam_lambda_role_manifest" {
  name = local.iam_lambda_role_manifest
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "local.iam_lambda_role_manifest"
  }
}

resource "aws_iam_role_policy" "iam_lambda_manifest_policy_ddb_read_access" {
  name = local.iam_lambda_manifest_policy_ddb_read_access
  role = aws_iam_role.iam_lambda_role_manifest.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "application-autoscaling:DescribeScalableTargets",
                "application-autoscaling:DescribeScalingActivities",
                "application-autoscaling:DescribeScalingPolicies",
                "cloudwatch:DescribeAlarmHistory",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DescribeAlarmsForMetric",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricData",
                "datapipeline:DescribeObjects",
                "datapipeline:DescribePipelines",
                "datapipeline:GetPipelineDefinition",
                "datapipeline:ListPipelines",
                "datapipeline:QueryObjects",
                "dynamodb:BatchGetItem",
                "dynamodb:Describe*",
                "dynamodb:List*",
                "dynamodb:GetItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:PartiQLSelect",
                "dax:Describe*",
                "dax:List*",
                "dax:GetItem",
                "dax:BatchGetItem",
                "dax:Query",
                "dax:Scan",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "iam:GetRole",
                "iam:ListRoles",
                "kms:DescribeKey",
                "kms:ListAliases",
                "sns:ListSubscriptionsByTopic",
                "sns:ListTopics",
                "lambda:ListFunctions",
                "lambda:ListEventSourceMappings",
                "lambda:GetFunctionConfiguration",
                "resource-groups:ListGroups",
                "resource-groups:ListGroupResources",
                "resource-groups:GetGroup",
                "resource-groups:GetGroupQuery",
                "tag:GetResources",
                "kinesis:ListStreams",
                "kinesis:DescribeStream",
                "kinesis:DescribeStreamSummary"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": "cloudwatch:GetInsightRuleReport",
            "Effect": "Allow",
            "Resource": "arn:aws:cloudwatch:*:*:insight-rule/DynamoDBContributorInsights*"
        }
    ]
  })
}

resource "aws_iam_role_policy" "lambda-manifest-policy-cloudwatch-logs" {
  name = local.iam_lambda_manifest_policy_cloudwatch_logs
  role = aws_iam_role.iam_lambda_role_manifest.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
  })
}
