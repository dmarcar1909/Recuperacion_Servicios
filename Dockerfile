# Usa una imagen base con Apache + PHP + MySQLi
FROM php:8.2-apache

# Habilitar la extensión mysqli
RUN docker-php-ext-install mysqli

# Copiar el código de tu aplicación
COPY componentes/ /var/www/html/

# Establecer permisos recomendados
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

EXPOSE 80

