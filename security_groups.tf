resource "aws_security_group" "node_application" {
  name = "Security Group Node Application"
  description = "Allow connection over the port 5000"

  # Using our own VPC
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Node Application port ingress"
    from_port = 5000
    to_port   = 5000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Node Application  port egress"
    from_port = 0
    to_port   = 0
    protocol  = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security Group Node Application"
  }
}

resource "aws_security_group" "database" {
  name = "Security Group Database"
  description = "Allow connection over the port 5432"

  # Using our own VPC
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Postgres Database port ingress"
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [aws_security_group.node_application.id]
  }

  egress {
    description = "Postgres Database port egress"
    from_port = 0
    to_port   = 0
    protocol  = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security Group Database"
  }
}