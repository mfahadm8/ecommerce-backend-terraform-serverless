
output "vpc_id" {
  value = aws_vpc.backend_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}

output "lambda_security_group_id" {
  value = aws_security_group.lambda_sg.id
}
