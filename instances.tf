resource "aws_instance" "ftp" {
  ami                         = "ami-0c7217cdde317cfec"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.vpc1_public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg_ftp.id]
  key_name                    = aws_key_pair.main_key.key_name
  user_data                   = data.template_file.bootstrap_ftp.rendered
  tags = {
    Name = "ftp-server"
  }
}

resource "aws_instance" "ldap" {
  ami                         = "ami-0c7217cdde317cfec"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.vpc2_private.id
  vpc_security_group_ids      = [aws_security_group.sg_ldap.id]
  key_name                    = aws_key_pair.main_key.key_name
  user_data                   = data.template_file.bootstrap_ldap.rendered
  depends_on = [
    aws_nat_gateway.nat_gw_vpc2,
    aws_route_table_association.assoc_vpc2_private
  ]
  tags = {
    Name = "ldap-server"
  }
}