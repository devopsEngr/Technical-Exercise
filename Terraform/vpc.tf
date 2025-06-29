resource "aws_vpc" "my_custom_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "hello_app_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_custom_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.my_custom_vpc.cidr_block, 8, count.index)
  count = length(var.vpc_availability_zones)
  availability_zone = element(var.vpc_availability_zones, count.index)

  tags = {
    Name = "hello_app_public_subnet ${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_custom_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.my_custom_vpc.cidr_block, 8, count.index+2)
  count = length(var.vpc_availability_zones)
  availability_zone = element(var.vpc_availability_zones, count.index)

  tags = {
    Name = "hello_app_private_subnet ${count.index+2}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_custom_vpc.id

  tags = {
    Name = "hello_app_igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
   
  }
  tags = {
    Name = "hello_app_public_route_table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count = length(var.vpc_availability_zones)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
  
}

resource "aws_eip" "eip" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.igw ]
  tags = {
    Name = "hello_app_eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  
  subnet_id     = element(aws_subnet.public_subnet[*].id, 0)
 allocation_id = aws_eip.eip.id
 depends_on = [ aws_internet_gateway.igw ]
  tags = {
    Name = "hello_app_nat_gw"
  }
}
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id

  }
  tags = {
    Name = "hello_app_private_route_table"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count = length(var.vpc_availability_zones)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id

}