# Proyecto DHCP + DNS + DDNS + Ansible

Este proyecto implementa una infraestructura completa con:

- Servidores **DHCP** (IPv4 y IPv6)
- Servidores **DNS** (Primario y Secundario, con sincronización y zonas)
- **Actualización dinámica (DDNS)** con clave TSIG
- Gestión completa con **Ansible** (roles, plantillas, tareas automatizadas)
- **Clientes Ubuntu y Windows**
- Comprobaciones de resolución directa, inversa, dinámica

---

## ✅ Comprobaciones obligatorias

### 🔧 Servidor DHCP

```bash
ip a
```

- IP asignada por DHCP dentro del rango
- DNS y dominio entregado correctamente

```bash
cat /etc/resolv.conf
resolvectl status
```

- Verificar `nameserver 127.0.0.53` y `DNS Servers: 192.168.53.1`

---

### 🔍 Resolución directa (nombre → IP)

```bash
nslookup cliente-ubuntu.damian.local 192.168.53.1
dig @192.168.53.1 cliente-ubuntu.damian.local
```

Debe devolver la IP correspondiente.

---

### 🔁 Resolución inversa (IP → nombre)

```bash
nslookup 192.168.60.132 192.168.53.1
dig -x 192.168.60.132 @192.168.53.1
```

Debe devolver el nombre `cliente-ubuntu.damian.local`.

---

### 🧠 Actualización dinámica

Verificar que el archivo `/var/lib/bind/db.damian.local` contenga el registro dinámico:

```
cliente-ubuntu   IN  A 192.168.60.132
```

Y que se haya creado automáticamente al encender el cliente.

---

## 🪟 Desde Windows

```cmd
ipconfig /all
nslookup cliente-ubuntu.damian.local
```

- Verificar IP, DNS (192.168.53.1) y sufijo `damian.local`
- Comprobaciones de resolución como en Ubuntu

---

## 🧪 Comandos útiles para ver logs

### DHCP

```bash
journalctl -u isc-dhcp-server.service -f
```

### DNS

```bash
journalctl -u bind9 -f
rndc freeze damian.local
cat /var/lib/bind/db.damian.local
rndc thaw damian.local
```

---

## 🛠 Automatización

Todo está gestionado con Ansible en `site.yml`, usando roles (`dns`, `dhcp-server`...).

Ejecutar con:

```bash
ansible-playbook -i inventories/hosts/hosts.ini site.yml --tags "dns,dhcp"
```

---
