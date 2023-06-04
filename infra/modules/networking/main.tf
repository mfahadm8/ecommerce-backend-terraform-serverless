data "aws_availability_zones" "available" {}

resource "aws_vpc" "backend_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private_subnets" {
  count             = 3 * length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.backend_vpc.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, count.index % length(data.aws_availability_zones.available.names))
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.backend_vpc.id
  cidr_block        = "10.0.100.0/24"                                         # Adjust the CIDR block as per your requirements
  availability_zone = element(data.aws_availability_zones.available.names, 0) # Specify the desired availability zone for the public subnet
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.backend_vpc.id
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.backend_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.backend_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "private_association" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_security_group"
  description = "Security group for RDS PostgreSQL"

  vpc_id = aws_vpc.backend_vpc.id

  # Inbound rule allowing access from Lambda security group
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda_security_group"
  description = "Security group for Lambda function"

  vpc_id = aws_vpc.backend_vpc.id

  # Inbound rule allowing access from RDS security group
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.rds_sg.id]
  }

  # Outbound rule allowing all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Additional inbound rules if necessary
}
