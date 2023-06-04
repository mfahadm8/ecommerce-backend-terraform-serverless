resource "aws_db_subnet_group" "ecommerce_db_subnet_group" {
  name        = "ecommerce-db-subnet-group"
  description = "Ecommerce DB subnet group"
  subnet_ids  = var.subnet_ids
}
resource "aws_db_instance" "postgres_instance" {
  identifier             = var.db_instance_identifier
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  publicly_accessible    = false
  allocated_storage      = 10
  vpc_security_group_ids = [var.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.ecommerce_db_subnet_group.name
  # backup_retention_period   = 7   # as per best practices, one should configure backup of db as well but I am commenting it for now
  # backup_window             = "03:00-04:00"
  # maintenance_window        = "mon:03:00-mon:04:00"
  deletion_protection   = true
  monitoring_interval   = 60
  monitoring_role_arn   = aws_iam_role.db_monitoring_role.arn
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.db_kms_key.arn
  copy_tags_to_snapshot = true
  apply_immediately     = true


  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_iam_role" "db_monitoring_role" {
  name = "db_monitoring_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "monitoring.rds.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "rds_instance_monitoring_policy" {
  name   = "ecommerce_sqs_read_delete_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds:CreateDBInstance",
        "rds:DeleteDBInstance",
        "rds:ModifyDBInstance",
        "rds:RebootDBInstance",
        "rds:DescribeDBInstances",
        "rds:DescribeDBInstanceAttribute",
        "rds:ListTagsForResource"
      ],
      "Resource": "arn:aws:rds:${var.aws_region}:${var.account_id}:db:${var.db_instance_identifier}"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "rds_role_policy_attachment" {
  policy_arn = aws_iam_policy.rds_instance_monitoring_policy.arn
  role       = aws_iam_role.db_monitoring_role.name

}


resource "aws_kms_key" "db_kms_key" {
  description             = "KMS key for RDS database encryption"
  deletion_window_in_days = 30
  is_enabled              = true
  enable_key_rotation     = true

}


resource "aws_secretsmanager_secret" "postgres_db_credentials" {
  name = "pg-db-credentials"
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name = "PostgresDB Credentials"
  }
}


resource "aws_secretsmanager_secret_version" "postgres_db_credentials_version" {
  secret_id = aws_secretsmanager_secret.postgres_db_credentials.id
  secret_string = jsonencode({
    username = aws_db_instance.postgres_instance.username
    password = aws_db_instance.postgres_instance.password
    engine   = aws_db_instance.postgres_instance.engine
    host     = aws_db_instance.postgres_instance.endpoint
    port     = aws_db_instance.postgres_instance.port
  })

  provisioner "local-exec" {
    command = <<EOF
    aws rds-data execute-statement --resource-arn ${aws_db_instance.postgres_instance.arn} --secret-arn ${aws_secretsmanager_secret.postgres_db_credentials.arn} --database ${aws_db_instance.postgres_instance.db_name} --sql "CREATE TABLE Orders (id SERIAL PRIMARY KEY, order_number VARCHAR(50), customer_name VARCHAR(100)); CREATE TABLE ProductInfo (id SERIAL PRIMARY KEY, product_name VARCHAR(100), stock_count INTEGER);"
    EOF
  }
}

