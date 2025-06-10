# VPC2 Configuration
resource "aws_vpc" "vpc2" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "vpc2-apache-ldap"
  }
}

# Subred pública (Apache)
resource "aws_subnet" "vpc2_public" {
  vpc_id                  = aws_vpc.vpc2.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "vpc2-public-subnet"
  }
}

# Subred privada (LDAP)
resource "aws_subnet" "vpc2_private" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "vpc2-private-subnet"
  }
}

# Internet Gateway para la subred pública
resource "aws_internet_gateway" "igw_vpc2" {
  vpc_id = aws_vpc.vpc2.id
}

# Tabla de rutas pública
resource "aws_route_table" "rt_vpc2_public" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc2.id
  }
}

# Asociación tabla de rutas pública
resource "aws_route_table_association" "assoc_vpc2_public" {
  subnet_id      = aws_subnet.vpc2_public.id
  route_table_id = aws_route_table.rt_vpc2_public.id
}

# NAT Gateway para que LDAP tenga salida a internet
resource "aws_eip" "eip_nat_vpc2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw_vpc2" {
  allocation_id = aws_eip.eip_nat_vpc2.id
  subnet_id     = aws_subnet.vpc2_public.id

  tags = {
    Name = "nat-gw-vpc2"
  }
}

# Tabla de rutas privada para LDAP con salida a internet por NAT y peering a VPC1
resource "aws_route_table" "rt_vpc2_private" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_vpc2.id
  }

  route {
    cidr_block                = aws_vpc.vpc1.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_vpc2.id
  }
}

# Asociar tabla privada a subred LDAP
resource "aws_route_table_association" "assoc_vpc2_private" {
  subnet_id      = aws_subnet.vpc2_private.id
  route_table_id = aws_route_table.rt_vpc2_private.id
}

# IP elástica Apache
resource "aws_eip_association" "apache_assoc" {
  instance_id   = aws_instance.apache.id
  allocation_id = "eipalloc-0948b3f091facffb0" # Cambiando ID IP Elástica
}


