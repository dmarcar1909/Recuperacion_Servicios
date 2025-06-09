#!/bin/bash
apt update -y
apt install -y docker.io docker-compose unzip

mkdir -p /opt/ldap
cd /opt/ldap
docker-compose up -d