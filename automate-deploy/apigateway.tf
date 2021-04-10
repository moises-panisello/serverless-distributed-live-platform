## PROJECT: serverless-distributed-live-platform ##
## Set up the environment * 10a ##
## Set up API Gateway ##
## Create the API gateway and connect the entry points with manifest lambda ##
## https://github.com/jordicenzano/serverless-distributed-live-platform/blob/master/docs/setup-api-gateway.md ##

resource "aws_api_gateway_rest_api" "api_gw_rest_api_distributed_transcoding" {
  body = jsonencode({
    "swagger" : "2.0",
    "info" : {
        "description" : "Live distributed transcoding",
        "version" : "2021-01-03T20:10:33Z",
        "title" : "local.aws_apigateway_name"
    },
    "schemes" : [ "https" ],
    "paths" : {
        "/video" : {
        "options" : {
            "consumes" : [ "application/json" ],
            "produces" : [ "application/json" ],
            "responses" : {
            "200" : {
                "description" : "200 response",
                "schema" : {
                "$ref" : "#/definitions/Empty"
                },
                "headers" : {
                "Access-Control-Allow-Origin" : {
                    "type" : "string"
                },
                "Access-Control-Allow-Methods" : {
                    "type" : "string"
                },
                "Access-Control-Allow-Headers" : {
                    "type" : "string"
                }
                }
            }
            },
            "x-amazon-apigateway-integration" : {
            "type" : "mock",
            "responses" : {
                "default" : {
                "statusCode" : "200",
                "responseParameters" : {
                    "method.response.header.Access-Control-Allow-Methods" : "'OPTIONS'",
                    "method.response.header.Access-Control-Allow-Headers" : "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
                    "method.response.header.Access-Control-Allow-Origin" : "'*'"
                }
                }
            },
            "requestTemplates" : {
                "application/json" : "{\"statusCode\": 200}"
            },
            "passthroughBehavior" : "when_no_match"
            }
        }
        },
        "/video/{streamID}" : {
        "options" : {
            "consumes" : [ "application/json" ],
            "produces" : [ "application/json" ],
            "responses" : {
            "200" : {
                "description" : "200 response",
                "schema" : {
                "$ref" : "#/definitions/Empty"
                },
                "headers" : {
                "Access-Control-Allow-Origin" : {
                    "type" : "string"
                },
                "Access-Control-Allow-Methods" : {
                    "type" : "string"
                },
                "Access-Control-Allow-Headers" : {
                    "type" : "string"
                }
                }
            }
            },
            "x-amazon-apigateway-integration" : {
            "type" : "mock",
            "responses" : {
                "default" : {
                "statusCode" : "200",
                "responseParameters" : {
                    "method.response.header.Access-Control-Allow-Methods" : "'OPTIONS'",
                    "method.response.header.Access-Control-Allow-Headers" : "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
                    "method.response.header.Access-Control-Allow-Origin" : "'*'"
                }
                }
            },
            "requestTemplates" : {
                "application/json" : "{\"statusCode\": 200}"
            },
            "passthroughBehavior" : "when_no_match"
            }
        }
        },
        "/video/{streamID}/manifest.m3u8" : {
        "get" : {
            "consumes" : [ "application/json" ],
            "produces" : [ "application/vnd.apple.mpegurl" ],
            "parameters" : [ {
            "name" : "latency",
            "in" : "query",
            "required" : false,
            "type" : "string"
            }, {
            "name" : "fromEpochS",
            "in" : "query",
            "required" : false,
            "type" : "string"
            }, {
            "name" : "liveType",
            "in" : "query",
            "required" : false,
            "type" : "string"
            }, {
            "name" : "chunksLatency",
            "in" : "query",
            "required" : false,
            "type" : "string"
            }, {
            "name" : "chunksNumber",
            "in" : "query",
            "required" : false,
            "type" : "string"
            }, {
            "name" : "streamID",
            "in" : "path",
            "required" : true,
            "type" : "string"
            } ],
            "responses" : {
            "200" : {
                "description" : "200 response",
                "schema" : {
                "$ref" : "#/definitions/Empty"
                },
                "headers" : {
                "Access-Control-Allow-Origin" : {
                    "type" : "string"
                }
                }
            },
            "400" : {
                "description" : "400 response"
            },
            "500" : {
                "description" : "500 response"
            }
            },
            "x-amazon-apigateway-integration" : {
            "type" : "aws",
            "uri" : "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda_manifest.arn}/invocations",
            "httpMethod" : "POST",
            "responses" : {
                "default" : {
                "statusCode" : "200",
                "responseParameters" : {
                    "method.response.header.Access-Control-Allow-Origin" : "'*'"
                },
                "responseTemplates" : {
                    "application/json" : "$input.path('$.body')\n#set($context.responseOverride.header.Cache-Control = $input.path('$.headers.Cache-Control'))\n#set($context.responseOverride.status = $input.path('$.statusCode'))\n#set($context.responseOverride.header.Access-Control-Allow-Headers = 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token')\n#set($context.responseOverride.header.Access-Control-Allow-Methods = 'GET,OPTIONS')\n#set($context.responseOverride.header.Access-Control-Allow-Origin = '*')"
                }
                }
            },
            "requestTemplates" : {
                "application/json" : "{\n    \"pathParameters\": {\n       \"streamID\":  \"$input.params('streamID')\",\n       \"renditionID\":  \"$input.params('renditionID')\"\n    },\n    \"queryStringParameters\": {\n        \"liveType\":  \"$input.params('liveType')\", \n        \"chunksLatency\": \"$input.params('chunksLatency')\",\n        \"fromEpochS\": \"$input.params('fromEpochS')\",\n        \"chunksNumber\": \"$input.params('chunksNumber')\",\n        \"toEpochS\": \"$input.params('toEpochS')\",\n        \"latency\": \"$input.params('latency')\"\n    }\n}"
            },
            "passthroughBehavior" : "when_no_templates",
            "cacheNamespace" : "ap2wsj",
            "cacheKeyParameters" : [ "method.request.path.streamID", "method.request.querystring.chunksLatency", "method.request.querystring.chunksNumber", "method.request.querystring.fromEpochS", "method.request.querystring.liveType", "method.request.querystring.latency" ],
            "contentHandling" : "CONVERT_TO_TEXT"
            }
        },
        "options" : {
            "consumes" : [ "application/json" ],
            "produces" : [ "application/json" ],
            "responses" : {
            "200" : {
                "description" : "200 response",
                "schema" : {
                "$ref" : "#/definitions/Empty"
                },
                "headers" : {
                "Access-Control-Allow-Origin" : {
                    "type" : "string"
                },
                "Access-Control-Allow-Methods" : {
                    "type" : "string"
                },
                "Access-Control-Allow-Headers" : {
                    "type" : "string"
                }
                }
            }
            },
            "x-amazon-apigateway-integration" : {
            "type" : "mock",
            "responses" : {
                "default" : {
                "statusCode" : "200",
                "responseParameters" : {
                    "method.response.header.Access-Control-Allow-Methods" : "'GET,OPTIONS'",
                    "method.response.header.Access-Control-Allow-Headers" : "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
                    "method.response.header.Access-Control-Allow-Origin" : "'*'"
                }
                }
            },
            "requestTemplates" : {
                "application/json" : "{\"statusCode\": 200}"
            },
            "passthroughBehavior" : "when_no_match"
            }
        }
        },
        "/video/{streamID}/{renditionID}" : {
        "options" : {
            "consumes" : [ "application/json" ],
            "produces" : [ "application/json" ],
            "responses" : {
            "200" : {
                "description" : "200 response",
                "schema" : {
                "$ref" : "#/definitions/Empty"
                },
                "headers" : {
                "Access-Control-Allow-Origin" : {
                    "type" : "string"
                },
                "Access-Control-Allow-Methods" : {
                    "type" : "string"
                },
                "Access-Control-Allow-Headers" : {
                    "type" : "string"
                }
                }
            }
            },
            "x-amazon-apigateway-integration" : {
            "type" : "mock",
            "responses" : {
                "default" : {
                "statusCode" : "200",
                "responseParameters" : {
                    "method.response.header.Access-Control-Allow-Methods" : "'OPTIONS'",
                    "method.response.header.Access-Control-Allow-Headers" : "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
                    "method.response.header.Access-Control-Allow-Origin" : "'*'"
                }
                }
            },
            "requestTemplates" : {
                "application/json" : "{\"statusCode\": 200}"
            },
            "passthroughBehavior" : "when_no_match"
            }
        }
        },
        "/video/{streamID}/{renditionID}/chunklist.m3u8" : {
        "get" : {
            "consumes" : [ "application/json" ],
            "produces" : [ "application/vnd.apple.mpegurl" ],
            "parameters" : [ {
            "name" : "latency",
            "in" : "query",
            "required" : false,
            "type" : "string"
            }, {
            "name" : "fromEpochS",
            "in" : "query",
            "required" : false,
            "type" : "string"
            }, {
            "name" : "toEpochS",
            "in" : "query",
            "required" : false,
            "type" : "string"
            }, {
            "name" : "liveType",
            "in" : "query",
            "required" : false,
            "type" : "string"
            }, {
            "name" : "chunksLatency",
            "in" : "query",
            "required" : false,
            "type" : "string"
            }, {
            "name" : "renditionID",
            "in" : "path",
            "required" : true,
            "type" : "string"
            }, {
            "name" : "chunksNumber",
            "in" : "query",
            "required" : false,
            "type" : "string"
            }, {
            "name" : "streamID",
            "in" : "path",
            "required" : true,
            "type" : "string"
            } ],
            "responses" : {
            "200" : {
                "description" : "200 response",
                "schema" : {
                "$ref" : "#/definitions/Empty"
                },
                "headers" : {
                "Access-Control-Allow-Origin" : {
                    "type" : "string"
                }
                }
            }
            },
            "x-amazon-apigateway-integration" : {
            "type" : "aws",
            "uri" : "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda_manifest.arn}/invocations",
            "httpMethod" : "POST",
            "responses" : {
                "default" : {
                "statusCode" : "200",
                "responseParameters" : {
                    "method.response.header.Access-Control-Allow-Origin" : "'*'"
                },
                "responseTemplates" : {
                    "application/json" : "$input.path('$.body')\n#set($context.responseOverride.header.Cache-Control = $input.path('$.headers.Cache-Control'))\n#set($context.responseOverride.status = $input.path('$.statusCode'))"
                }
                }
            },
            "requestTemplates" : {
                "application/json" : "{\n    \"pathParameters\": {\n       \"streamID\":  \"$input.params('streamID')\",\n       \"renditionID\":  \"$input.params('renditionID')\"\n    },\n    \"queryStringParameters\": {\n        \"liveType\":  \"$input.params('liveType')\", \n        \"chunksLatency\": \"$input.params('chunksLatency')\",\n        \"fromEpochS\": \"$input.params('fromEpochS')\",\n        \"chunksNumber\": \"$input.params('chunksNumber')\",\n        \"toEpochS\": \"$input.params('toEpochS')\",\n        \"latency\": \"$input.params('latency')\"\n    }\n}"
            },
            "passthroughBehavior" : "when_no_templates",
            "cacheNamespace" : "zr3nnh",
            "cacheKeyParameters" : [ "method.request.path.renditionID", "method.request.path.streamID", "method.request.path.renditionID", "method.request.path.streamID", "method.request.querystring.chunksLatency", "method.request.querystring.chunksNumber", "method.request.querystring.fromEpochS", "method.request.querystring.liveType", "method.request.querystring.toEpochS", "method.request.querystring.latency" ],
            "contentHandling" : "CONVERT_TO_TEXT"
            }
        },
        "options" : {
            "consumes" : [ "application/json" ],
            "produces" : [ "application/json" ],
            "responses" : {
            "200" : {
                "description" : "200 response",
                "schema" : {
                "$ref" : "#/definitions/Empty"
                },
                "headers" : {
                "Access-Control-Allow-Origin" : {
                    "type" : "string"
                },
                "Access-Control-Allow-Methods" : {
                    "type" : "string"
                },
                "Access-Control-Allow-Headers" : {
                    "type" : "string"
                }
                }
            }
            },
            "x-amazon-apigateway-integration" : {
            "type" : "mock",
            "responses" : {
                "default" : {
                "statusCode" : "200",
                "responseParameters" : {
                    "method.response.header.Access-Control-Allow-Methods" : "'GET,OPTIONS'",
                    "method.response.header.Access-Control-Allow-Headers" : "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
                    "method.response.header.Access-Control-Allow-Origin" : "'*'"
                }
                }
            },
            "requestTemplates" : {
                "application/json" : "{\"statusCode\": 200}"
            },
            "passthroughBehavior" : "when_no_match"
            }
        }
        }
    },
    "definitions" : {
        "Empty" : {
        "type" : "object",
        "title" : "Empty Schema"
        }
    }
  })
  name = local.aws_apigateway_name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "api_gw_deployment_distributed_transcoding" {
  rest_api_id = aws_api_gateway_rest_api.api_gw_rest_api_distributed_transcoding.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api_gw_rest_api_distributed_transcoding.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_gw_stage_distributed_transcoding" {
  deployment_id = aws_api_gateway_deployment.api_gw_deployment_distributed_transcoding.id
  rest_api_id   = aws_api_gateway_rest_api.api_gw_rest_api_distributed_transcoding.id
  stage_name    = "prod"
  cache_cluster_enabled = true
  cache_cluster_size = "0.5"
}

resource "null_resource" "api_gw_stage_distributed_transcoding_patch-operations" {
  provisioner "local-exec" {
    command = <<CMD_GW_PATCH_OP
aws --region ${var.aws_region} apigateway update-stage --rest-api-id ${aws_api_gateway_rest_api.api_gw_rest_api_distributed_transcoding.id} --stage-name prod --patch-operations "op=replace,path=/*/*/caching/ttlInSeconds,value=1"
CMD_GW_PATCH_OP
  }
  depends_on = [aws_api_gateway_stage.api_gw_stage_distributed_transcoding]
}

output "api_gw_deployment_distributed_transcoding_invoke_url" {
  value       = aws_api_gateway_deployment.api_gw_deployment_distributed_transcoding.invoke_url
  description = "API Gateway's Invoke URL."
}
