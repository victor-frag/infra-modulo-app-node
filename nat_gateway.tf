# Create an Elastic Ip to be used on the NAT Gateway
resource "aws_eip" "elastic_ip" {
  vpc = true
}

# Create a VPC NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id

  # Public subnet
  subnet_id = aws_subnet.public_subnet.id
  
  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "NAT Gateway"
  }
}

# Create a NAT VPC Route Table
resource "aws_route_table" "nat_route_table" {
  
  # Using our own VPC
  vpc_id = aws_vpc.vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "NAT Gateway Route Table"
  }
}

# Create an association between a Route Table and a Subnet
resource "aws_route_table_association" "nat_route_associations" {
  # Private Subnet
  subnet_id = aws_subnet.private_subnet.id
  
  # Reference for the NAT VPC Route Table
  route_table_id = aws_route_table.nat_route_table.id
}