#!/bin/bash
apt update
apt install -y docker.io
systemctl enable docker
systemctl start docker

# Crear directorios
mkdir -p /home/ubuntu/apache-ldap/html/idiomas
mkdir -p /home/ubuntu/apache-ldap/htaccess
mkdir -p /home/ubuntu/apache-ldap/html/vhost1
mkdir -p /home/ubuntu/apache-ldap/html/vhost2

# Espacio de usuarios
mkdir -p /home/ubuntu/apache-ldap/home/usuario1/public_html
echo '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>Página personal de usuario1</h1></body></html>' > /home/usuario1/public_html/index.html
chmod -R a+rx /home/ubuntu/apache-ldap/home/usuario1

cd /home/ubuntu/apache-ldap

# Páginas principales multilenguaje con .var
cat <<EOF > html/index.var
URI: index

URI: index.html.en
Content-type: text/html
Content-language: en

URI: index.html.es
Content-type: text/html
Content-language: es

EOF

cat <<EOF > html/index.html.en
<h1>Custom Root Page</h1>
<meta charset="UTF-8">
<p>The Apache server now listens on port 8080 and this is its new DocumentRoot.</p>
EOF

cat <<EOF > html/index.html.es
<h1>Página raíz personalizada</h1>
<meta charset="UTF-8">
<p>Ahora el servidor Apache escucha en el puerto 8080 y este es su nuevo DocumentRoot.</p>
EOF

cat <<EOF > html/inicio.var
URI: inicio

URI: inicio.html.en
Content-type: text/html
Content-language: en

URI: inicio.html.es
Content-type: text/html
Content-language: es

EOF

cat <<EOF > html/inicio.html.en
<h1>Welcome</h1>
<meta charset="UTF-8">
<p>You are viewing the English version of the main page.</p>
EOF

cat <<EOF > html/inicio.html.es
<h1>Bienvenido</h1>
<meta charset="UTF-8">
<p>Estás viendo la versión en español de la página principal.</p>
EOF

# HTML protegido
cat <<EOF > html/privado.html
<h1>Contenido protegido</h1>
<meta charset="UTF-8">
<p>Solo accesible con usuario LDAP</p>
EOF

# Archivo .htaccess
cat <<EOF > htaccess/.htaccess
AuthType Basic
AuthName "Zona protegida"
AuthBasicProvider ldap
AuthLDAPURL ldap://10.1.2.18:389/ou=usuarios,dc=damian,dc=com?uid
AuthLDAPBindDN "cn=admin,dc=damian,dc=com"
AuthLDAPBindPassword admin
Require valid-user
EOF

# Archivos en distintos idiomas
cat <<EOF > html/idiomas/bienvenida.var
URI: bienvenida

URI: bienvenida.html.en
Content-type: text/html
Content-language: en

URI: bienvenida.html.es
Content-type: text/html
Content-language: es

EOF


cat <<EOF > html/idiomas/bienvenida.en.html
<h1>Welcome</h1>
<meta charset="UTF-8">
<p>This is the English welcome page.</p>
EOF

cat <<EOF > html/idiomas/bienvenida.es.html
<h1>Bienvenido</h1>
<meta charset="UTF-8">
<p>Esta es la página de bienvenida en español.</p>
EOF

# Contenido de vhost1
cat <<EOF > html/vhost1/index.html
<h1>Bienvenido a vhost1.damian.local</h1>
<p>Este es el sitio virtual número 1</p>
EOF

# Contenido de vhost2
cat <<EOF > html/vhost2/index.html
<h1>Bienvenido a vhost2.damian.local</h1>
<p>Este es el sitio virtual número 2</p>
EOF

# Archivo de configuración adicional
cat <<EOF > apache-ldap.conf
DocumentRoot "/usr/local/apache2/html"

ErrorLog /proc/self/fd/2
LogLevel debug

Listen 443

# Sitio principal (con dominio real público)
#<VirtualHost *:8080>
#    ServerName damian.work.gd
#    DocumentRoot "/usr/local/apache2/html"
#
#    <Directory "/usr/local/apache2/html">
#        Options Indexes FollowSymLinks
#        AllowOverride All
#        Require all granted
#        DirectoryIndex inicio.var index.var
#    </Directory>
#</VirtualHost>

<VirtualHost *:8080>
    ServerName damian.work.gd
    Redirect permanent / https://damian.work.gd/
</VirtualHost>

<VirtualHost *:443>
    ServerName damian.work.gd
    DocumentRoot "/usr/local/apache2/html"

    SSLEngine on
    SSLCertificateFile "/usr/local/apache2/conf/ssl/apache.crt"
    SSLCertificateKeyFile "/usr/local/apache2/conf/ssl/apache.key"

    <Directory "/usr/local/apache2/html">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
	DirectoryIndex inicio.var index.var
    </Directory>
</VirtualHost>

# Sitio virtual 1
#<VirtualHost *:8080>
#    ServerName vhost1.damian.work.gd
#    DocumentRoot "/usr/local/apache2/html/vhost1"
#
#    <Directory "/usr/local/apache2/html/vhost1">
#        Options Indexes FollowSymLinks
#        AllowOverride None
#        Require all granted
#        DirectoryIndex index.html
#    </Directory>
#</VirtualHost>

<VirtualHost *:8080>
    ServerName vhost1.damian.work.gd
    Redirect permanent / https://vhost1.damian.work.gd/
</VirtualHost>

<VirtualHost *:443>
    ServerName vhost1.damian.work.gd
    DocumentRoot "/usr/local/apache2/html/vhost1"

    <Directory "/usr/local/apache2/html/vhost1">
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
        DirectoryIndex index.html
    </Directory>
</VirtualHost>

# Sitio virtual 2
#<VirtualHost *:8080>
#    ServerName vhost2.damian.work.gd
#    DocumentRoot "/usr/local/apache2/html/vhost2"
#
#    <Directory "/usr/local/apache2/html/vhost2">
#        Options Indexes FollowSymLinks
#        AllowOverride None
#        Require all granted
#        DirectoryIndex index.html
#    </Directory>
#</VirtualHost>

<VirtualHost *:8080>
    ServerName vhost2.damian.work.gd
    Redirect permanent / https://vhost2.damian.work.gd/
</VirtualHost>

<VirtualHost *:443>
    ServerName vhost2.damian.work.gd
    DocumentRoot "/usr/local/apache2/html/vhost2"

    <Directory "/usr/local/apache2/html/vhost2">
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
        DirectoryIndex index.html
    </Directory>
</VirtualHost>

<Directory "/usr/local/apache2/html/idiomas">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
    DirectoryIndex bienvenida.var
</Directory>

Redirect "/inicio" "/privado.html"

<IfModule !ldap_module>
    LoadModule ldap_module modules/mod_ldap.so
</IfModule>
<IfModule !authnz_ldap_module>
    LoadModule authnz_ldap_module modules/mod_authnz_ldap.so
</IfModule>
<IfModule !auth_basic_module>
    LoadModule auth_basic_module modules/mod_auth_basic.so
</IfModule>
<IfModule !authz_core_module>
    LoadModule authz_core_module modules/mod_authz_core.so
</IfModule>
<IfModule !negotiation_module>
    LoadModule negotiation_module modules/mod_negotiation.so
</IfModule>
<IfModule !alias_module>
    LoadModule alias_module modules/mod_alias.so
</IfModule>
<IfModule !authz_host_module>
    LoadModule authz_host_module modules/mod_authz_host.so
</IfModule>
<IfModule !include_module>
    LoadModule include_module modules/mod_include.so
</IfModule>
<IfModule !userdir_module>
    LoadModule userdir_module modules/mod_userdir.so
</IfModule>
<IfModule !ssl_module>
    LoadModule ssl_module modules/mod_ssl.so
</IfModule>

UserDir public_html
UserDir enabled usuario1

<Directory "/home/*/public_html">
    AllowOverride None
    Options Indexes FollowSymLinks
    Require all granted
</Directory>

Include conf/extra/httpd-multilang-errordoc.conf

AddHandler type-map .var
AddLanguage en .en
AddLanguage es .es
LanguagePriority es en
ForceLanguagePriority Prefer Fallback

EOF

# Dockerfile
cat <<EOF > Dockerfile
FROM httpd:2.4

RUN sed -i 's/Listen 80/Listen 8080/' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's#DocumentRoot \"/usr/local/apache2/htdocs\"#DocumentRoot \"/usr/local/apache2/html\"#' /usr/local/apache2/conf/httpd.conf

RUN useradd -m usuario1

COPY html/ /usr/local/apache2/html/
COPY htaccess/.htaccess /usr/local/apache2/html/
COPY htaccess/.htaccess /usr/local/apache2/html/vhost1/
COPY htaccess/.htaccess /usr/local/apache2/html/vhost2/
COPY apache-ldap.conf /usr/local/apache2/conf/extra/
COPY home/ /home/

RUN echo "IncludeOptional conf/extra/apache-ldap.conf" >> /usr/local/apache2/conf/httpd.conf

RUN apt update && apt install -y ldap-utils

# Instalar OpenSSL y habilitar SSL en Apache
RUN apt update && \
    apt install -y openssl && \
    mkdir -p /usr/local/apache2/conf/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /usr/local/apache2/conf/ssl/apache.key \
      -out /usr/local/apache2/conf/ssl/apache.crt \
      -subj "/C=ES/ST=Andalucia/L=Granada/O=Iliberis/OU=ASIR/CN=damian.work.gd"

EXPOSE 8080 443
EOF

# Lanzar contenedor
docker build -t apache-ldap .
docker run -d -p 8080:8080 -p 443:443 --name apache-ldap apache-ldap
