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