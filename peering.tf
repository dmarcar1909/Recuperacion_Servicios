resource "aws_vpc_peering_connection" "vpc1_vpc2" {
  vpc_id        = aws_vpc.vpc1.id
  peer_vpc_id   = aws_vpc.vpc2.id
  auto_accept   = true
  tags = {
    Name = "ftp-ldap-peering"
  }
}

resource "aws_route" "vpc1_to_vpc2" {
  route_table_id             = aws_route_table.rt_vpc1_public.id
  destination_cidr_block     = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.vpc1_vpc2.id
}

resource "aws_route" "vpc2_to_vpc1_public" {
  route_table_id             = aws_route_table.rt_vpc2_public.id
  destination_cidr_block     = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.vpc1_vpc2.id
}