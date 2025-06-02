#!/bin/bash
apt update
apt install -y docker.io
systemctl enable docker
systemctl start docker

mkdir -p /srv/nginx/html
echo "Bienvenido al Frontend Nginx" > /srv/nginx/html/index.html

mkdir -p /srv/nginx/conf
cat <<EOF > /srv/nginx/conf/default.conf
server {
    listen 80;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }

    location /backend/ {
        proxy_pass https://${apache_private_ip}/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

docker run -d \
  --name nginx-server \
  -p 80:80 \
  -v /srv/nginx/html:/usr/share/nginx/html \
  -v /srv/nginx/conf/default.conf:/etc/nginx/conf.d/default.conf \
  nginx:latest
S
