output "ldap_private_ip" {
  description = "IP privada del servidor LDAP (solo accesible desde FTP)"
  value       = aws_instance.ldap.private_ip
}

output "ftp_public_ip" {
  description = "IP pública del servidor FTP (asociada automáticamente)"
  value       = aws_instance.ftp.public_ip
}