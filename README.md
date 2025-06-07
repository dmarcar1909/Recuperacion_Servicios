# Proyecto Kubernetes - Tienda de Componentes

Este proyecto consiste en desplegar una aplicación web desarrollada en PHP con conexión a base de datos MySQL en un clúster de Kubernetes.  
La infraestructura está pensada para funcionar tanto en Minikube (local) como en un clúster EKS de AWS.

---

## 📁 Estructura del repositorio

```
├── .github/
│   └── workflows/
│       └── deploy.yml       # Workflow de GitHub Actions para aplicar los YAML al clúster
├── docker/
│   ├── Dockerfile           # Dockerfile para construir la imagen web
│   └── init.sql             # Script para inicializar la base de datos
├── k8s/
│   ├── web-deployment.yaml
│   ├── web-service.yaml
│   ├── db-deployment.yaml
│   ├── db-service.yaml
│   └── pvc.yaml
```

---

## 🚀 Despliegue en Minikube

Para validar que todo funciona correctamente, se ha desplegado la app en Minikube:

```bash
minikube start --memory=3000mb --driver=docker
kubectl apply -f k8s/
minikube service web-service
```

> La aplicación carga correctamente en el navegador.  
> La conexión a la base de datos falla por defecto (`localhost`) pero se puede arreglar modificando `conexion.php` para que use `mysql-service` como host.

---

## ☁️ Despliegue en AWS (EKS)

El clúster `componentes-cluster` fue creado desde la consola gráfica de AWS (como pedía la práctica).

- Versión de Kubernetes: 1.33
- Región: `us-east-1`
- Nodos: no funcionales debido a limitaciones de la cuenta educativa

El workflow `deploy.yml` está listo para lanzar automáticamente los archivos YAML al clúster desde GitHub Actions.

```yaml
aws eks update-kubeconfig --name componentes-cluster
kubectl apply -f k8s/
```

---

## ⚠️ Notas sobre la cuenta de AWS Educate

- No permite crear o asociar roles IAM personalizados (ej: para LoadBalancer)
- No permite lanzar nodos correctamente (`NodeCreationFailure`)
- Por eso no se puede probar la app completa en EKS, pero **los archivos están 100 % listos**


---

## 🧪 Cómo usar y comprobar esta práctica

1. **Opción A: en Minikube (recomendado para validación local)**

```bash
minikube start --memory=3000mb --driver=docker
kubectl apply -f k8s/
minikube service web-service
```

2. **Opción B: desde GitHub Actions contra EKS**

> Solo funcionará si el clúster tiene nodos activos y permisos habilitados.

```bash
# Configura credenciales con configure-aws-credentials
# Luego:
aws eks update-kubeconfig --name componentes-cluster
kubectl apply -f k8s/
```

3. Accede a la aplicación desde el navegador usando la URL proporcionada por `minikube service web-service`.


---

## 📝 Notas sobre el proyecto web

Esta página web fue desarrollada por mí el año pasado como parte de otro módulo.  
Debido al tiempo transcurrido, no he podido encontrar la **versión final**, sino una versión **anterior e incompleta**.

Aun así, es totalmente funcional a efectos de esta práctica, ya que permite probar correctamente la conexión a la base de datos, los contenedores, y el despliegue en Kubernetes.


## 💡 Conclusión

- La infraestructura está montada
- Los archivos están preparados para lanzarse tanto en Minikube como en EKS
- El despliegue se ha validado de forma funcional en local

---

## ✍️ Autor

Damián Martín Carrasco  
2º ASIR – Servicios en Red
