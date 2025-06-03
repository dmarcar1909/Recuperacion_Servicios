# Infraestructura Web con Terraform + Docker + GitHub Actions

Este proyecto despliega una infraestructura en AWS usando Terraform, contenedores Docker y automatización con GitHub Actions.

## 📦 Servicios desplegados

- 🐳 **Nginx**: Servidor público en la VPC1. Sirve contenido web estático y actúa como proxy inverso para acceder al backend.
- 🐳 **Apache**: Backend en la VPC2 (subred pública), configurado con:
  - Directorio raíz personalizado (`/usr/local/apache2/html`)
  - Autenticación con LDAP para rutas protegidas
  - Espacio de usuarios (`mod_userdir`)
  - HTTPS con certificados autofirmados
  - Redireccionamientos automáticos de HTTP a HTTPS
  - Páginas de error personalizadas
  - Negociación de contenido (idiomas)
  - Sitios virtuales (VirtualHosts)
  - Alias `/backend/` configurado para servir el backend
- 🐳 **LDAP (OpenLDAP)**: Servidor en la subred privada de VPC2, accesible solo desde Apache.

## ⚙️ Automatización

### 📥 `deploy.yml`
Se ejecuta automáticamente al hacer `git push` a la rama `WEB`. Ejecuta:

```bash
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

### 🧹 `destroy.yml`
Se ejecuta manualmente desde GitHub Actions (`workflow_dispatch`). Ejecuta:

```bash
terraform init -reconfigure
terraform validate
terraform state list
terraform plan -destroy
terraform destroy -auto-approve
```

## ☁️ Backend remoto (S3)

El estado (`terraform.tfstate`) se almacena en un bucket S3:
- Sincronización automática entre entorno local y GitHub Actions.
- Seguridad y consistencia en el despliegue y destrucción de recursos.

---

## 🔁 Proxy inverso con Nginx → Apache

El Nginx está configurado para actuar como proxy inverso:

```nginx
location /backend/ {
    proxy_pass http://<ip_privada_apache>:443;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

> 🔒 Como Apache sirve por HTTPS, se puede usar `proxy_pass https://...` si se desea mantener cifrado punto a punto. Actualmente se permite por el puerto 443 interno.

En Apache se define un `Alias` y un `Directory` para `/backend/` en el `VirtualHost` de HTTPS:

```apache
Alias /backend/ "/usr/local/apache2/html/"

<Directory "/usr/local/apache2/html/">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
    DirectoryIndex inicio.var index.var
</Directory>
```

---

## ✅ Cómo verificar el correcto funcionamiento

1. Visita: `http://<ip_elástica_nginx>/backend/`
2. Debe redirigir internamente a Apache y devolver la página configurada.
3. Si se requiere autenticación, introduce usuario/contraseña LDAP.
4. También puedes probar `curl` desde la instancia de Nginx:
   ```bash
   curl http://10.1.1.XXX/backend/
   ```
5. Para validar HTTPS directamente:
   ```bash
   curl -k https://<ip_privada_apache>/
   ```

---

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

- Desde GitHub Actions: Ejecutar el workflow `Terraform Destroy`.
- O desde local:

```bash
terraform destroy
```

---

## ✅ Requisitos cumplidos (Checklist)

| Requisito                                             | Estado        |
|------------------------------------------------------|---------------|
| Infraestructura en AWS dividida en 2 VPC             | ✅ Cumplido   |
| Nginx en subred pública (VPC1)                       | ✅ Cumplido   |
| Apache en subred pública (VPC2)                      | ✅ Cumplido   |
| LDAP en subred privada (VPC2), accesible por Apache  | ✅ Cumplido   |
| Todos los servicios en contenedores Docker           | ✅ Cumplido   |
| Terraform automatizado con GitHub Actions            | ✅ Cumplido   |
| Backend en S3 funcionando                            | ✅ Cumplido   |
| HTTPS configurado en Apache                          | ✅ Cumplido   |
| Autenticación LDAP en Apache                         | ✅ Cumplido   |
| Redirecciones + páginas de error + userdir           | ✅ Cumplido   |
| Negociación de contenido y sitios virtuales          | ✅ Cumplido   |
| Deploy automático + Destroy manual                   | ✅ Cumplido   |
| Proxy inverso Nginx → Apache                         | ✅ Cumplido   |

---

## 📁 Estructura del repositorio

```
.
├── main.tf
├── instances.tf
├── outputs.tf
├── variables.tf
├── peering.tf
├── vpc1.tf
├── vpc2.tf
├── lanzador.txt
├── scripts/
│   ├── bootstrap_apache.sh.tpl
│   ├── bootstrap_nginx.sh.tpl
│   └── bootstrap_ldap.sh
├── htaccess/
│   └── .htaccess
├── .github/
│   └── workflows/
│       ├── deploy.yml
│       └── destroy.yml
└── .gitignore
```

---

## 🧠 Autor

Damian — 2º ASIR — Proyecto: Infraestructura Web Automatizada 🚀
