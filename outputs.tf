output "ldap_private_ip" {
  description = "IP privada del servidor LDAP (solo accesible desde Apache)"
  value       = aws_instance.ldap.private_ip
}

output "nginx_public_ip" {
  description = "IP pública del servidor Nginx (asociada manualmente)"
  value       = "18.206.34.224"
}

output "apache_public_ip" {
  description = "IP pública del servidor Apache (asociada manualmente)"
  value       = "18.205.102.76"
}
