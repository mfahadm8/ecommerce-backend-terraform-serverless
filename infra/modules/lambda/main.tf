
data "archive_file" "create_order_function_package" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/CreateOrderFunction"
  output_path = "${path.module}/../../src/create_order_function_package.zip"

}

resource "aws_lambda_function" "create_order_function" {
  function_name    = var.create_order_function_name
  handler          = "index.handler"
  runtime          = "python3.10"
  role             = aws_iam_role.create_order_function_role.arn
  source_code_hash = filebase64sha256(data.archive_file.create_order_function_package.output_path)
  filename         = "create_order_function_package.zip"

  environment {
    variables = {
      ORDER_PROCESSING_QUEUE_URL = var.order_processing_queue_url
    }
  }
  depends_on = [aws_lambda_function.update_stocks_function]
}

data "archive_file" "get_customer_orders_function_package" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/GetCustomerOrdersFunction"
  output_path = "${path.module}/../../src/get_customer_orders_function_package.zip"

}

resource "aws_lambda_function" "get_customer_orders_function" {
  function_name    = var.get_customer_orders_function_name
  handler          = "index.handler"
  runtime          = "python3.10"
  role             = aws_iam_role.get_customer_orders_function_role.arn
  source_code_hash = filebase64sha256(data.archive_file.get_customer_orders_function_package.output_path)
  filename         = "get_customer_orders_function_package.zip"
  depends_on       = [aws_lambda_function.update_stocks_function]
}

data "archive_file" "process_order_function_package" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/ProcessOrderFunction"
  output_path = "${path.module}/../../src/process_order_function_package.zip"

}

resource "aws_lambda_function" "process_order_function" {
  function_name    = var.process_order_function_name
  handler          = "index.handler"
  runtime          = "python3.10"
  role             = aws_iam_role.process_order_function_role.arn
  source_code_hash = filebase64sha256(data.archive_file.process_order_function_package.output_path)
  filename         = "process_order_function_package.zip"
  depends_on       = [aws_lambda_function.update_stocks_function]
  environment {
    variables = {
      UPDATE_STOCKS_QUEUE_URL = var.update_stocks_queue_url
    }
  }
}

data "archive_file" "update_stocks_function_package" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/UpdateStocksFunction"
  output_path = "${path.module}/../../src/update_stocks_function_package.zip"

}

resource "aws_lambda_function" "update_stocks_function" {
  function_name    = var.update_stocks_function_name
  handler          = "index.handler"
  runtime          = "python3.10"
  role             = aws_iam_role.update_stocks_function_role.arn
  source_code_hash = filebase64sha256(data.archive_file.update_stocks_function_package.output_path)
  filename         = "update_stocks_function_package.zip"
  depends_on       = [aws_lambda_function.update_stocks_function]
}


resource "aws_lambda_permission" "order_processing_lambda_queue_permission" {
  statement_id  = "AllowLambdaOrderProcessingQueue"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_order_function.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.update_stocks_queue.arn
}

resource "aws_lambda_permission" "update_stocks_lambda_queue_permission" {
  statement_id  = "AllowLambdaUpdateStocksQueue"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_stocks_function.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.order_processing_queue.arn
}


resource "aws_iam_policy" "ecommerce_db_secrets_read_policy" {
  name   = "ecommerce_db_secrets_read_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:${var.db_username_secret_name}"
        "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:${var.db_password_secret_name}"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_policy" "ecommerce_order_processing_sqs_read_delete_policy" {
  name   = "ecommerce_order_processing_sqs_read_delete_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:DeleteMessage"
      ],
      "Resource": [
        "arn:aws:sqs:${var.region}:${var.account_id}:${var.orders_processing_queue_name}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecommerce_update_stocks_read_delete_policy" {
  name   = "ecommerce_update_stocks_read_delete_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:DeleteMessage"
      ],
      "Resource": [
        "arn:aws:sqs:${var.region}:${var.account_id}:${var.update_stocks_queue_name}"
      ]
    }
  ]
}
EOF
}



resource "aws_iam_role" "create_order_function_role" {
  name = "create-order-function-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "create_order_function_role_policy_attachment" {
  for_each = toset([
    aws_iam_policy.ecommerce_db_secrets_read_policy.arn,
    aws_iam_policy.ecommerce_update_stocks_read_delete_policy.arn,
    aws_iam_policy.ecommerce_order_processing_sqs_read_delete_policy.arn
  ])

  role       = aws_iam_role.create_order_function_role.arn
  policy_arn = each.value
}

resource "aws_iam_role" "get_customer_orders_function_role" {
  name = "get-customer-orders-function-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "get_customer_orders_function_role_policy_attachment" {
  for_each = toset([
    aws_iam_policy.ecommerce_db_secrets_read_policy.arn,
    aws_iam_policy.ecommerce_update_stocks_read_delete_policy.arn,
    aws_iam_policy.ecommerce_order_processing_sqs_read_delete_policy.arn
  ])

  role       = aws_iam_role.get_customer_orders_function_role.arn
  policy_arn = each.value
}

resource "aws_iam_role" "process_order_function_role" {
  name = "process-order-function-package"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "process_order_function_role_policy_attachment" {
  for_each = toset([
    aws_iam_policy.ecommerce_db_secrets_read_policy.arn,
    aws_iam_policy.ecommerce_update_stocks_read_delete_policy.arn,
    aws_iam_policy.ecommerce_order_processing_sqs_read_delete_policy.arn
  ])

  role       = aws_iam_role.process_order_function_role.arn
  policy_arn = each.value
}

resource "aws_iam_role" "update_stocks_function_role" {
  name = "update-stocks-function-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "update_stocks_function_role_policy_attachment" {
  for_each = toset([
    aws_iam_policy.ecommerce_db_secrets_read_policy.arn,
    aws_iam_policy.ecommerce_update_stocks_read_delete_policy.arn,
    aws_iam_policy.ecommerce_order_processing_sqs_read_delete_policy.arn
  ])

  role       = aws_iam_role.update_stocks_function_role.arn
  policy_arn = each.value
}

