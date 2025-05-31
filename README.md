# Infraestructura Web con Terraform + Docker + GitHub Actions

Este proyecto despliega una infraestructura en AWS usando Terraform, contenedores Docker y automatización con GitHub Actions.

## 📦 Servicios desplegados

- 🐳 **Nginx**: Servidor público en la VPC1, sirve contenido web estático.
- 🐳 **Apache**: Backend en la VPC2 (subred pública), configurado con:
  - Directorio raíz personalizado
  - Autenticación con LDAP
  - Espacio de usuarios (`mod_userdir`)
  - HTTPS con certificados autofirmados
  - Redireccionamientos, páginas de error personalizadas, negociación de contenido, sitios virtuales
- 🐳 **LDAP (OpenLDAP)**: Servidor en la subred privada de VPC2, accesible solo desde Apache.

## ⚙️ Automatización

### 📥 `deploy.yml`
Se ejecuta automáticamente al hacer `git push` a la rama `WEB`. Lanza:
```bash
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

### 🧹 `destroy.yml`
Se ejecuta manualmente desde GitHub Actions (`workflow_dispatch`). Realiza:
```bash
terraform init -reconfigure
terraform validate
terraform state list
terraform plan -destroy
terraform destroy -auto-approve
```

## ☁️ Backend remoto (S3)

El estado (`terraform.tfstate`) se almacena y sincroniza en un bucket S3:
- Permite que tanto GitHub Actions como el entorno local trabajen sobre el mismo estado.
- Garantiza que las destrucciones sean completas.

## 🧪 Cómo usar

### 🔧 Requisitos previos

- Crear un bucket S3 y configurar `backend` en `main.tf`.
- Configurar secretos en GitHub:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_SESSION_TOKEN`

### ▶️ Desplegar infraestructura

```bash
# Hacer push a la rama WEB
git push origin WEB
```
O manualmente:
```bash
terraform init
terraform apply
```

### 🧹 Destruir infraestructura

- Ejecutar el workflow `Terraform Destroy` desde la pestaña **Actions**.
O desde local:
```bash
terraform destroy
```

## ✅ Requisitos cumplidos (Checklist)

| Requisito                                             | Estado  |
|------------------------------------------------------|---------|
| Infraestructura en AWS dividida en 2 VPC             | ✅ Cumplido |
| Nginx en subred pública (VPC1)                       | ✅ Cumplido |
| Apache en subred pública (VPC2)                      | ✅ Cumplido |
| LDAP en subred privada (VPC2), accesible por Apache  | ✅ Cumplido |
| Todos los servicios en contenedores Docker           | ✅ Cumplido |
| Terraform automatizado con GitHub Actions            | ✅ Cumplido |
| Backend en S3 funcionando                            | ✅ Cumplido |
| HTTPS configurado en Apache                          | ✅ Cumplido |
| Autenticación LDAP en Apache                         | ✅ Cumplido |
| Redirecciones + páginas de error + userdir           | ✅ Cumplido |
| Negociación de contenido y sitios virtuales          | ✅ Cumplido |
| Deploy automático + Destroy manual                   | ✅ Cumplido |

## 📁 Estructura del repositorio

```
.
├── main.tf
├── instances.tf
├── outputs.tf
├── variables.tf
├── scripts/
│   ├── bootstrap_apache.sh.tpl
│   └── bootstrap_ldap.sh
├── html/
│   └── privado.html
├── htaccess/
│   └── .htaccess
├── Dockerfile
├── docker-compose.yml
├── .github/
│   └── workflows/
│       ├── deploy.yml
│       └── destroy.yml
```

## 🧠 Autor

Damian — 2º ASIR — Proyecto: Infraestructura Web Automatizada 🚀
