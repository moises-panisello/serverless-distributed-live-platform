## PROJECT: serverless-distributed-live-platform ##
## Set up the environment * 9 ##
## Set up Dynamo DB ##
## Create table for configurations,
##  create table for chunks metadata with its GSI (used by manifest creation)
##  and populate config table ##
## https://github.com/jordicenzano/serverless-distributed-live-platform/blob/master/docs/setup-ddb.md ##

resource "aws_dynamodb_table" "config-dynamodb-table" {
  name           = local.ddb_config_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "config_name"
  attribute {
    name = "config_name"
    type = "S"
  }
  tags = {
    Name        = "local.ddb_config_table_name"
  }
}

resource "aws_dynamodb_table" "chunks-dynamodb-table" {
  name           = local.ddb_chunks_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "uid"
  range_key      = "stream-id"
  attribute {
    name = "stream-id"
    type = "S"
  }
  attribute {
    name = "uid"
    type = "S"
  }
  attribute {
    name = "wallclock-epoch-ns"
    type = "N"
  }
  attribute {
    name = "stream-id"
    type = "S"
  }
  global_secondary_index {
    name               = "stream-id-wallclock-epoch-ns-index"
    hash_key           = "stream-id"
    range_key          = "wallclock-epoch-ns"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "ALL"
  }
  tags = {
    Name        = "local.ddb_chunks_table_name"
  }
}

## KEEP IN MIND ##
## The key originally named "config-name" has been replaced with "config_name"
##  to avoid the following issue:
## https://github.com/hashicorp/terraform-provider-aws/issues/10385

resource "aws_dynamodb_table_item" "aws_dynamodb_config_table_item" {
  table_name = aws_dynamodb_table.config-dynamodb-table.name
  hash_key   = aws_dynamodb_table.config-dynamodb-table.hash_key

  item = <<ITEM
{
  "config_name": {
    "S": "default"
  },
  "desc": {
    "S": "1080p SLOW (Premium 5 renditions)"
  },
  "value": {
    "M": {
      "copyOriginalContentTypeToABRChunks": {
        "BOOL": true
      },
      "copyOriginalMetadataToABRChunks": {
        "BOOL": true
      },
      "mediaCdnPrefix": {
        "S": "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
      },
      "overlayEncodingData": {
        "BOOL": true
      },
      "overlayMessage": {
        "S": "Test-"
      },
      "publicReadToABRChunks": {
        "BOOL": false
      },
      "renditions": {
        "L": [
          {
            "M": {
              "height": {
                "N": "1080"
              },
              "ID": {
                "S": "1080p"
              },
              "video_buffersize": {
                "N": "12000000"
              },
              "video_crf": {
                "N": "23"
              },
              "video_h264_bpyramid": {
                "S": "strict"
              },
              "video_h264_preset": {
                "S": "slow"
              },
              "video_h264_profile": {
                "S": "high"
              },
              "video_maxrate": {
                "N": "6000000"
              },
              "width": {
                "N": "1920"
              }
            }
          },
          {
            "M": {
              "height": {
                "N": "720"
              },
              "ID": {
                "S": "720p"
              },
              "video_buffersize": {
                "N": "8000000"
              },
              "video_crf": {
                "N": "23"
              },
              "video_h264_bpyramid": {
                "S": "strict"
              },
              "video_h264_preset": {
                "S": "slow"
              },
              "video_h264_profile": {
                "S": "high"
              },
              "video_maxrate": {
                "N": "4000000"
              },
              "width": {
                "N": "1280"
              }
            }
          },
          {
            "M": {
              "height": {
                "N": "540"
              },
              "ID": {
                "S": "540p"
              },
              "video_buffersize": {
                "N": "4000000"
              },
              "video_crf": {
                "N": "23"
              },
              "video_h264_bpyramid": {
                "S": "strict"
              },
              "video_h264_preset": {
                "S": "slow"
              },
              "video_h264_profile": {
                "S": "high"
              },
              "video_maxrate": {
                "N": "2000000"
              },
              "width": {
                "N": "960"
              }
            }
          },
          {
            "M": {
              "height": {
                "N": "360"
              },
              "ID": {
                "S": "360p"
              },
              "video_buffersize": {
                "N": "730000"
              },
              "video_crf": {
                "N": "23"
              },
              "video_h264_bpyramid": {
                "S": "strict"
              },
              "video_h264_preset": {
                "S": "slow"
              },
              "video_h264_profile": {
                "S": "high"
              },
              "video_maxrate": {
                "N": "365000"
              },
              "width": {
                "N": "640"
              }
            }
          },
          {
            "M": {
              "height": {
                "N": "234"
              },
              "ID": {
                "S": "234p"
              },
              "video_buffersize": {
                "N": "290000"
              },
              "video_crf": {
                "N": "23"
              },
              "video_h264_bpyramid": {
                "S": "strict"
              },
              "video_h264_preset": {
                "S": "slow"
              },
              "video_h264_profile": {
                "S": "high"
              },
              "video_maxrate": {
                "N": "145000"
              },
              "width": {
                "N": "416"
              }
            }
          }
        ]
      },
      "s3OutputPrefix": {
        "S": "output/"
      },
      "video_pix_fmt": {
        "S": "yuv420p"
      }
    }
  }
}
ITEM
}
