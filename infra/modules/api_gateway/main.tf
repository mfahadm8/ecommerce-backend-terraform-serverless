

resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = var.api_gateway_name
  description = "API Gateway for the application"
}

resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "create_order" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
}

resource "aws_api_gateway_integration" "create_order_integration" {
  rest_api_id         = aws_api_gateway_rest_api.api_gateway.id
  resource_id         = aws_api_gateway_resource.root.id
  http_method         = aws_api_gateway_method.create_order.http_method
  integration_http_method = "POST"
  type                = "AWS_PROXY"
  uri                 = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.create_order_lambda_arn}/invocations"
}

resource "aws_api_gateway_method" "get_customer_orders" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
}

resource "aws_api_gateway_integration" "get_customer_orders_integration" {
  rest_api_id         = aws_api_gateway_rest_api.api_gateway.id
  resource_id         = aws_api_gateway_resource.root.id
  http_method         = aws_api_gateway_method.get_customer_orders.http_method
  integration_http_method = "POST"
  type                = "AWS_PROXY"
  uri                 = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.get_customer_orders_lambda_arn}/invocations"
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name        = "API Gateway Usage Plan"
  description = "Usage plan for API Gateway"
  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway.id
    stage  = "prod"
  }
}

resource "aws_api_gateway_api_key" "api_key" {
  name = "API Key for the application"
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}
