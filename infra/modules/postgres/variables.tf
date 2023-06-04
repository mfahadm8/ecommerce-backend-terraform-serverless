variable "aws_region" {
  description = "Aws region"
}
variable "account_id" {
  description = "Current Aws Account Id"
}
variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = []
}
variable "db_instance_identifier" {
  description = "Identifier for the PostgresDB instance"
  type        = string
}

variable "db_name" {
  description = "Name of the PostgresDB"
  type        = string
}

variable "db_username" {
  description = "Username for accessing the PostgresDB"
  type        = string
}

variable "db_password" {
  description = "Password for accessing the PostgresDB"
  type        = string
}
variable "rds_security_group_id" {
  description = "Security group for PosgressDB"
  type        = string
}
