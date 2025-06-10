#!/bin/bash
apt update
apt install -y docker.io docker-compose
systemctl enable docker
systemctl start docker

# Crear directorio de trabajo
mkdir -p /home/ubuntu/openldap
cd /home/ubuntu/openldap

# Crear archivo LDIF
cat <<EOF > bootstrap.ldif
dn: ou=usuarios,dc=damian,dc=com
objectClass: organizationalUnit
ou: usuarios

dn: uid=admin,ou=usuarios,dc=damian,dc=com
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
cn: admin
sn: admin
uid: admin
userPassword: admin
EOF

# Crear Dockerfile con bootstrap incluido
cat <<EOF > Dockerfile
FROM osixia/openldap:1.5.0
COPY bootstrap.ldif /container/service/slapd/assets/config/bootstrap/ldif/custom/bootstrap.ldif
EOF

# Crear archivo docker-compose.yml
cat <<EOF > docker-compose.yml
version: '3'
services:
  ldap:
    build: .
    container_name: ldap-server
    ports:
      - "389:389"
    environment:
      LDAP_ORGANISATION: "Damian Servicios"
      LDAP_DOMAIN: "damian.com"
      LDAP_ADMIN_PASSWORD: "admin"
    restart: always
EOF

# Lanzar el contenedor con Docker Compose
docker-compose up -d

