
# Create the API Gateway REST API
resource "aws_apigatewayv2_api" "api" {
  name          = "MyAPI"
  protocol_type = "HTTP"
}

# Create the API Gateway Cognito authorizer
resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  name          = "CognitoAuthorizer"
  api_id        = aws_apigatewayv2_api.api.id
  authorizer_type = "COGNITO_USER_POOLS"
  identity_source = "$request.header.Authorization"
  provider_arns  = [var.cognito_user_pool_arn]
}

# Create the API Gateway API key
resource "aws_apigatewayv2_api_key" "api_key" {
  name = "WebClientAPIKey"
}

# Create the API Gateway usage plan
resource "aws_apigatewayv2_usage_plan" "usage_plan" {
  name = "WebClientUsagePlan"
  api_stages {
    api_id   = aws_apigatewayv2_api.api.id
    stage    = "$default"
  }
  quota_settings {
    limit = 1000
    period = "MONTH"
  }
  throttle_settings {
    rate_limit = 500
    burst_limit = 1000
  }
}

# Associate the API key with the usage plan
resource "aws_apigatewayv2_api_key_association" "api_key_association" {
  api_id      = aws_apigatewayv2_api.api.id
  api_key_id  = aws_apigatewayv2_api_key.api_key.id
  stage_name  = "$default"
}

# Create the API Gateway integration with Lambda
resource "aws_apigatewayv2_integration" "create_order_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.create_order_lambda_arn
  integration_method     = "POST"
  connection_type        = "INTERNET"
  description            = "Lambda integration for CreateOrderFunction"
  passthrough_behavior   = "WHEN_NO_MATCH"

}

# Create the API Gateway route
resource "aws_apigatewayv2_route" "route" {
  api_id          = aws_apigatewayv2_api.api.id
  route_key       = "POST /orders"
  target          = "integrations/${aws_apigatewayv2_integration.create_order_lambda_integration.id}"
  authorization_type = "COGNITO_USER_POOLS"
  authorizer_id     = aws_apigatewayv2_authorizer.cognito_authorizer.id

  depends_on = [
    aws_apigatewayv2_integration.lambda_integration,
  ]
}

# Create the API Gateway integration with Lambda
resource "aws_apigatewayv2_integration" "get_customers_orders_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.get_customer_orders_lambda_arn
  integration_method     = "POST"
  connection_type        = "INTERNET"
  description            = "Lambda integration for GetCustomerOrdersFunction"
  passthrough_behavior   = "WHEN_NO_MATCH"

}

# Create the API Gateway route
resource "aws_apigatewayv2_route" "route" {
  api_id          = aws_apigatewayv2_api.api.id
  route_key       = "POST /orders"
  target          = "integrations/${aws_apigatewayv2_integration.get_customers_orders_lambda_integration.id}"
  authorization_type = "COGNITO_USER_POOLS"
  authorizer_id     = aws_apigatewayv2_authorizer.cognito_authorizer.id

  depends_on = [
    aws_apigatewayv2_integration.get_customers_orders_lambda_integration,
  ]
}
