
resource "aws_db_instance" "postgres_instance" {
  identifier          = var.db_instance_identifier
  engine              = "postgres"
  instance_class      = "db.t2.micro"
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  publicly_accessible = false

  vpc_security_group_ids = [aws_security_group.db_security_group.id]

  # backup_retention_period   = 7
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

  provisioner "local-exec" {
    command = "sleep 60" // Wait for the DB instance to be fully created before executing the following commands
  }

  provisioner "local-exec" {
    command = <<EOF
      psql -h ${aws_db_instance.postgres_instance.address} -U ${var.db_username} -p 5432 -d ${var.db_name} -c \
      "CREATE TABLE Orders (id SERIAL PRIMARY KEY, order_number VARCHAR(50), customer_name VARCHAR(100)); \
      CREATE TABLE ProductInfo (id SERIAL PRIMARY KEY, product_name VARCHAR(100), stock_count INTEGER);"
    EOF
  }
}

resource "aws_security_group" "db_security_group" {
  name        = "db_security_group"
  description = "Security group for RDS database"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Add any other necessary security group rules for the RDS database
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
  role       = aws_iam_role.db_monitoring_role.arn

}


resource "aws_kms_key" "db_kms_key" {
  description             = "KMS key for RDS database encryption"
  deletion_window_in_days = 30
  is_enabled              = true
  enable_key_rotation     = true

}


resource "aws_secretsmanager_secret" "postgres_db_credentials" {
  name = "postgres-db-credentials"

  tags = {
    Name = "PostgresDB Credentials"
  }
}

resource "aws_secretsmanager_secret_version" "postgres_db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.postgres_db_credentials.id
  secret_string = <<EOF
{ "dbname": "${var.db_name}",
  "username": "${var.db_username}",
  "password": "${var.db_password}"
}
EOF
}

