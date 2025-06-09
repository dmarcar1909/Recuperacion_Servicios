# Proyecto FTP + LDAP en AWS con Terraform y GitHub Actions

Este repositorio despliega una infraestructura completa de servidor FTP (ProFTPD) con autenticación LDAP, TLS, usuarios enjaulados, y almacenamiento S3, usando:

- **Terraform** para definir la infraestructura
- **Docker** para ejecutar los servicios
- **GitHub Actions** para automatizar despliegue y destrucción

---

## 🗂 Estructura del proyecto

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── instances.tf
├── vpc1.tf
├── vpc2.tf
├── peering.tf
├── scripts/
│   ├── bootstrap_ftp.sh.tpl
│   └── bootstrap_ldap.sh.tpl
├── docker/
│   ├── ftp/
│   │   ├── Dockerfile
│   │   ├── docker-compose.yml
│   │   ├── proftpd.conf
│   │   ├── tls.conf
│   │   ├── mod_ldap.conf
│   │   └── certs/
│   └── ldap/
│       ├── docker-compose.yml
│       └── certs/
└── .github/
    └── workflows/
        ├── deploy.yml
        └── destroy.yml
```

---

## ☁️ Infraestructura desplegada

- **VPC 1**: contiene la instancia FTP en una subred pública.
- **VPC 2**: contiene el servidor LDAP en una subred privada.
- **Peering entre VPCs**
- **NAT Gateway**: para que LDAP tenga acceso a internet.
- **Montaje S3**: se monta un bucket como volumen de datos en `/ftpdata`.

---

## 🚀 Despliegue automático

1. **Sube el proyecto a GitHub.**
2. **Ve a Settings → Secrets → Actions y añade:**
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `S3_BUCKET_NAME` (nombre del bucket a montar en /ftpdata)
3. **Haz push a la rama `main` para desplegar.**
4. **Desde GitHub → Actions → Destroy FTP Infra → `Run workflow` para destruir.**

---

## ✅ Requisitos del sistema

- Cuenta de AWS con permisos suficientes.
- Un bucket S3 creado para montar los datos.
- Clave pública SSH añadida en `main_key`.

---

## 📎 Notas adicionales

- El servidor FTP utiliza TLS (carga certificados desde `certs/`).
- El LDAP se basa en la imagen `osixia/openldap`.
- Los contenedores se lanzan automáticamente al crear las instancias EC2.

---

## 🧑‍💻 Autor

Proyecto generado automáticamente con ayuda de ChatGPT. Personalizado por: **Damian**