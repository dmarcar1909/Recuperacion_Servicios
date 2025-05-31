#!/bin/bash
apt update
apt install -y docker.io
systemctl enable docker
systemctl start docker

docker run -d -p 80:80 --name nginx-server nginx:latest
