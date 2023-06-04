data "aws_sqs_queue" "update_stocks_queue" {
  name = var.update_stocks_queue_name
}

data "aws_sqs_queue" "order_processing_queue" {
  name = var.order_processing_queue_name
}


data "archive_file" "create_order_function_package" {
  type        = "zip"
  source_dir  = "${path.root}/../src/CreateOrderFunction"
  output_path = "${path.root}/../tmp/create_order_function_package.zip"

}

resource "aws_lambda_function" "create_order_function" {
  function_name    = var.create_order_function_name
  handler          = "index.handler"
  runtime          = "python3.10"
  role             = aws_iam_role.create_order_function_role.arn
  source_code_hash = data.archive_file.create_order_function_package.output_base64sha256
  filename         = data.archive_file.create_order_function_package.output_path

  environment {
    variables = {
      ORDER_PROCESSING_QUEUE_URL = data.aws_sqs_queue.order_processing_queue.url
      PG_ENDPOINT                = var.pg_db_endpoint
    }
  }
  depends_on = [data.archive_file.create_order_function_package]
}

data "archive_file" "get_customer_orders_function_package" {
  type        = "zip"
  source_dir  = "${path.root}/../src/GetCustomerOrdersFunction"
  output_path = "${path.root}/../tmp/get_customer_orders_function_package.zip"

}

resource "aws_lambda_function" "get_customer_orders_function" {
  function_name    = var.get_customer_orders_function_name
  handler          = "index.handler"
  runtime          = "python3.10"
  role             = aws_iam_role.get_customer_orders_function_role.arn
  source_code_hash = data.archive_file.get_customer_orders_function_package.output_base64sha256
  filename         = data.archive_file.create_order_function_package.output_path
  depends_on       = [data.archive_file.get_customer_orders_function_package]

  vpc_config {
    subnet_ids         = [var.subnet_ids[0], var.subnet_ids[1]]
    security_group_ids = [var.lambda_security_group_id]
  }
  environment {
    variables = {
      PG_ENDPOINT = var.pg_db_endpoint
    }
  }
}

data "archive_file" "process_order_function_package" {
  type        = "zip"
  source_dir  = "${path.root}/../src/ProcessOrderFunction"
  output_path = "${path.root}/../tmp/process_order_function_package.zip"

}

resource "aws_lambda_function" "process_order_function" {
  function_name    = var.process_order_function_name
  handler          = "index.handler"
  runtime          = "python3.10"
  role             = aws_iam_role.process_order_function_role.arn
  source_code_hash = data.archive_file.process_order_function_package.output_base64sha256
  filename         = data.archive_file.create_order_function_package.output_path
  depends_on       = [data.archive_file.process_order_function_package]
  vpc_config {
    subnet_ids         = [var.subnet_ids[0], var.subnet_ids[1]]
    security_group_ids = [var.lambda_security_group_id]
  }
  environment {
    variables = {
      UPDATE_STOCKS_QUEUE_URL = data.aws_sqs_queue.update_stocks_queue.url
    }
  }
}

data "archive_file" "update_stocks_function_package" {
  type        = "zip"
  source_dir  = "${path.root}/../src/UpdateStocksFunction"
  output_path = "${path.root}/../tmp/update_stocks_function_package.zip"
}
resource "aws_lambda_function" "update_stocks_function" {
  function_name    = var.update_stocks_function_name
  handler          = "index.handler"
  runtime          = "python3.10"
  role             = aws_iam_role.update_stocks_function_role.arn
  source_code_hash = data.archive_file.update_stocks_function_package.output_base64sha256
  filename         = data.archive_file.create_order_function_package.output_path
  depends_on       = [data.archive_file.update_stocks_function_package]

  vpc_config {
    subnet_ids         = [var.subnet_ids[0], var.subnet_ids[1]]
    security_group_ids = [var.lambda_security_group_id]
  }
  environment {
    variables = {
      PG_ENDPOINT = var.pg_db_endpoint
    }
  }
}


resource "aws_lambda_permission" "order_processing_lambda_queue_permission" {
  statement_id  = "AllowLambdaOrderProcessingQueue"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_order_function.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = data.aws_sqs_queue.order_processing_queue.arn
}

resource "aws_lambda_permission" "update_stocks_lambda_queue_permission" {
  statement_id  = "AllowLambdaUpdateStocksQueue"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_stocks_function.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = data.aws_sqs_queue.update_stocks_queue.arn
}


resource "aws_iam_policy" "ecommerce_db_secrets_read_policy" {
  name   = "ecommerce-db-secrets-read-policy"
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
        "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:${var.db_username_secret_name}",
        "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:${var.db_password_secret_name}"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_policy" "ecommerce_order_processing_sqs_read_delete_policy" {
  name   = "ecommerce-order-processing-sqs-read-delete-policy"
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
        "arn:aws:sqs:${var.region}:${var.account_id}:${var.order_processing_queue_name}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecommerce_update_stocks_read_delete_policy" {
  name   = "ecommerce-update-stocks-read-delete-policy"
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

locals {
  policy_arns = [
    aws_iam_policy.ecommerce_db_secrets_read_policy.arn,
    aws_iam_policy.ecommerce_update_stocks_read_delete_policy.arn,
    aws_iam_policy.ecommerce_order_processing_sqs_read_delete_policy.arn
  ]
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
  count      = length(local.policy_arns)
  policy_arn = local.policy_arns[count.index]
  role       = aws_iam_role.create_order_function_role.name

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
  count      = length(local.policy_arns)
  policy_arn = local.policy_arns[count.index]
  role       = aws_iam_role.get_customer_orders_function_role.name

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
  count      = length(local.policy_arns)
  policy_arn = local.policy_arns[count.index]
  role       = aws_iam_role.process_order_function_role.name

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
  count      = length(local.policy_arns)
  policy_arn = local.policy_arns[count.index]
  role       = aws_iam_role.update_stocks_function_role.name

}

