#!/bin/bash
apt update
apt install -y docker.io
systemctl enable docker
systemctl start docker

# Crear una carpeta temporal con contenido HTML
mkdir -p /srv/nginx/html
echo "<h1>Bienvenido al Frontend Nginx</h1>" > /srv/nginx/html/index.html

# Crear archivo de configuración de Nginx con proxy_pass hacia Apache (usando IP elástica o dominio)
mkdir -p /srv/nginx/conf
cat > /srv/nginx/conf/default.conf <<EOF
server {
    listen 80;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }

    location /backend/ {
        proxy_pass http://18.205.102.76/;  # IP elástica de Apache
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Ejecutar contenedor Nginx sirviendo contenido local y configuración custom
docker run -d \
    --name nginx-server \
    -p 80:80 \
    -v /srv/nginx/html:/usr/share/nginx/html \
    -v /srv/nginx/conf/default.conf:/etc/nginx/conf.d/default.conf \
    nginx:latest
