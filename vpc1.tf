resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc1-ftp"
  }
}

resource "aws_subnet" "vpc1_public" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = {
    Name = "vpc1-public-subnet"
  }
}

resource "aws_internet_gateway" "igw_vpc1" {
  vpc_id = aws_vpc.vpc1.id
}

resource "aws_route_table" "rt_vpc1_public" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc1.id
  }
}

resource "aws_route_table_association" "assoc_vpc1" {
  subnet_id      = aws_subnet.vpc1_public.id
  route_table_id = aws_route_table.rt_vpc1_public.id
}