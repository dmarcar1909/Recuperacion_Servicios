# Par de claves para conectar por SSH (puedes personalizar o importar uno ya creado)
resource "aws_key_pair" "main_key" {
  key_name   = "web-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Security Group común para acceso público (HTTP/HTTPS, SSH, ICMP)
resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Permitir HTTP, HTTPS, SSH e ICMP"
 
 vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group para LDAP (solo accesible desde Apache)
resource "aws_security_group" "ldap_sg" {
  name        = "ldap-sg"
  description = "Permitir acceso LDAP solo desde Apache"
  vpc_id      = aws_vpc.vpc2.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg_vpc2.id]
  }

  ingress {
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    security_groups = [aws_security_group.public_sg_vpc2.id]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group para la subred pública de VPC2 (Apache)
resource "aws_security_group" "public_sg_vpc2" {
  name        = "public-sg-vpc2"
  description = "Permitir HTTP, HTTPS, SSH (VPC2)"
  vpc_id      = aws_vpc.vpc2.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc2-public-sg"
  }
}

resource "local_file" "rendered_bootstrap_apache" {
  content  = data.template_file.bootstrap_apache.rendered
  filename = "${path.module}/scripts/bootstrap_apache.sh"
}

# ----------------------------
# Instancia LDAP (VPC2 privada)
# ----------------------------
resource "aws_instance" "ldap" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.vpc2_private.id
  vpc_security_group_ids = [aws_security_group.ldap_sg.id]
  key_name               = aws_key_pair.main_key.key_name
  user_data              = file("${path.module}/scripts/bootstrap_ldap.sh")

  depends_on = [
    aws_nat_gateway.nat_gw_vpc2,
    aws_route_table_association.assoc_vpc2_private
  ]

  tags = {
    Name = "ldap-server"
  }
}
# ----------------------------
# Instancia Nginx (VPC1)
# ----------------------------
resource "aws_instance" "nginx" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.vpc1_public.id
  associate_public_ip_address = false
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name               = aws_key_pair.main_key.key_name
  user_data              = file("scripts/bootstrap_nginx.sh")

  tags = {
    Name = "nginx-server"
  }
}

# ----------------------------
# Instancia Apache (VPC2 pública)
# ----------------------------
resource "aws_instance" "apache" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  associate_public_ip_address = false
  subnet_id              = aws_subnet.vpc2_public.id
  vpc_security_group_ids = [aws_security_group.public_sg_vpc2.id]
  key_name               = aws_key_pair.main_key.key_name
  user_data = data.template_file.bootstrap_apache.rendered

  tags = {
    Name = "apache-server"
  }
}

data "template_file" "bootstrap_apache" {
  template = file("${path.module}/scripts/bootstrap_apache.sh.tpl")
  vars = {
    ldap_ip = aws_instance.ldap.private_ip
  }
}
