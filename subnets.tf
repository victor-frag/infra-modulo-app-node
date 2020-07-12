resource "aws_subnet" "private_subnet" {
  # Using our own VPC
  vpc_id = aws_vpc.vpc.id

  cidr_block = "192.168.15.0/24"

  # Indicate that instances launched into the subnet should be assigned a public IP address or not
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_subnet" "public_subnet" {
  # Using our own VPC
  vpc_id = aws_vpc.vpc.id

  cidr_block = "192.168.10.0/24"

  # Indicate that instances launched into the subnet should be assigned a public IP address or not
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  # Using our own VPC
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}

# Create a VPC Route Table
resource "aws_route_table" "internet_gateway_route_table" {
  # Using our own VPC
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Internet Gateway Route Table"
  }
}

# Create an association between a Route Table and a Subnet
resource "aws_route_table_association" "rt_association" {
  # Public Subnet
  subnet_id = aws_subnet.public_subnet.id

  # Reference for the Internet Gateway VPC Route Table
  route_table_id = aws_route_table.internet_gateway_route_table.id
}
