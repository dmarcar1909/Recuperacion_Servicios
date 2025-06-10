output "ldap_private_ip" {
  description = "IP privada del servidor LDAP (solo accesible desde Apache)"
  value       = aws_instance.ldap.private_ip
}

output "nginx_public_ip" {
  description = "IP pública del servidor Nginx (asociada manualmente)"
  value       = "52.204.227.70"
}

output "apache_public_ip" {
  description = "IP pública del servidor Apache (asociada manualmente)"
  value       = "54.173.5.158"
}
