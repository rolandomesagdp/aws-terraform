terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "rolandomesagdp-terraform-state-bucket"
    key     = "rolandomesagdp/terraform-state"
    region  = "eu-west-1"
    profile = "rolandomesagdp"
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "rolandomesagdp-aws-user"
}

resource "aws_api_gateway_rest_api" "configurators" {
  name = "configurators-v2"
}

resource "aws_api_gateway_resource" "analysis" {
  rest_api_id = aws_api_gateway_rest_api.configurators.id
  parent_id   = aws_api_gateway_rest_api.configurators.root_resource_id
  path_part   = "analysis"
  depends_on  = [aws_api_gateway_rest_api.configurators]
}

module "cors-visibility" {
  source          = "squidfunk/api-gateway-enable-cors/aws"
  version         = "0.3.3"
  api_id          = aws_api_gateway_rest_api.configurators.id
  api_resource_id = aws_api_gateway_resource.analysis.id
}

# resource "aws_api_gateway_method" "analysis_options" {
#   rest_api_id   = aws_api_gateway_rest_api.configurators.id
#   resource_id   = aws_api_gateway_resource.analysis.id
#   http_method   = "OPTIONS"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_method_response" "analysis_options_response" {
#   rest_api_id = aws_api_gateway_rest_api.configurators.id
#   resource_id = aws_api_gateway_resource.analysis.id
#   status_code = "200"
#   http_method = aws_api_gateway_method.analysis_options.http_method
#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Headers" = true
#     "method.response.header.Access-Control-Allow-Methods" = true
#     "method.response.header.Access-Control-Allow-Origin"  = true
#   }
# }

# resource "aws_api_gateway_integration" "analysis_options_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.configurators.id
#   resource_id             = aws_api_gateway_resource.analysis.id
#   http_method             = aws_api_gateway_method.analysis_options.http_method
#   type                    = "MOCK"
#   integration_http_method = "POST"
#   request_templates = {
#     "application/json" = jsonencode(
#       {
#         statusCode = 200
#       }
#     )
#   }
# }

# resource "aws_api_gateway_integration_response" "analysis_options_integration_response" {
#   rest_api_id = aws_api_gateway_rest_api.configurators.id
#   resource_id = aws_api_gateway_resource.analysis.id
#   status_code = aws_api_gateway_method_response.analysis_options_response.status_code
#   http_method = aws_api_gateway_method.analysis_options.http_method
#   response_parameters = {
#     "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
#     "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
#     "method.response.header.Access-Control-Allow-Origin"  = "'*'"
#   }
# }
resource "aws_api_gateway_deployment" "configurators_deployment" {
  rest_api_id = aws_api_gateway_rest_api.configurators.id
  stage_name  = "dev"
  depends_on = [
    aws_api_gateway_rest_api.configurators,
    aws_api_gateway_resource.analysis,
    module.cors-visibility
  ]
}
