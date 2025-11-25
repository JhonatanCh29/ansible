# 🔥 Rol: Firewall UFW - Configuración de Seguridad de Red

## 📋 **Descripción**

Este rol configura **UFW (Uncomplicated Firewall)** para proporcionar una capa de seguridad robusta en el sistema. Implementa políticas restrictivas, reglas personalizadas y monitoreo automatizado para cumplir con los estándares de **Nivel 4 Académico**.

## 🎯 **Funcionalidades Implementadas**

### **🔧 Configuración Básica:**
- ✅ Instalación automática de UFW
- ✅ Políticas por defecto: DENY incoming, ALLOW outgoing
- ✅ Reglas básicas: SSH (22), HTTP (80), HTTPS (443)
- ✅ Rate limiting para SSH (protección contra ataques de fuerza bruta)

### **🛡️ Seguridad Avanzada:**
- ✅ Logging configurable (off, low, medium, high, full)
- ✅ Backup automático de reglas
- ✅ Monitoreo automatizado con alertas
- ✅ Reglas personalizadas configurables
- ✅ Protección contra ping flooding (opcional)

### **📊 Monitoreo y Alertas:**
- ✅ Script de monitoreo cada 10 minutos
- ✅ Logging centralizado en `/var/log/ufw_monitor.log`
- ✅ Alertas automáticas si UFW se desactiva
- ✅ Conteo de conexiones bloqueadas

## ⚙️ **Variables Principales**

### **Configuración Básica:**
```yaml
firewall_enabled: true                    # Habilitar UFW
firewall_default_policy: 'deny'          # Política por defecto
firewall_allow_ssh: true                 # Permitir SSH
firewall_allow_http: true                # Permitir HTTP
firewall_allow_https: true               # Permitir HTTPS
firewall_logging: 'low'                  # Nivel de logging
```

### **Reglas Personalizadas:**
```yaml
firewall_custom_rules:
  - rule: allow
    port: '53'
    proto: udp
    comment: 'DNS queries'
  - rule: allow
    port: '3306'
    proto: tcp
    src: '192.168.1.0/24'
    comment: 'MySQL from LAN'
```

### **Configuración de Seguridad:**
```yaml
firewall_ssh_rate_limit: true           # Rate limiting SSH
firewall_block_ping: false              # Bloquear ping
firewall_monitoring: true               # Monitoreo automático
firewall_backup_rules: true             # Backup de reglas
```

## 🚀 **Uso del Rol**

### **En un Playbook:**
```yaml
- role: firewall
  tags: ['firewall', 'security', 'network']
  vars:
    firewall_enabled: true
    firewall_custom_rules:
      - rule: allow
        port: '8080'
        proto: tcp
        comment: 'Custom web service'
```

### **Ejecución con Tags:**
```bash
# Solo configurar firewall
ansible-playbook security_playbook.yml --tags firewall

# Solo reglas personalizadas
ansible-playbook security_playbook.yml --tags firewall_custom
```

## 🔍 **Verificación y Testing**

### **Comandos de Verificación:**
```bash
# Estado del firewall
sudo ufw status verbose

# Reglas numeradas
sudo ufw status numbered

# Logs del firewall
sudo tail -f /var/log/ufw.log

# Monitoreo personalizado
sudo tail -f /var/log/ufw_monitor.log
```

### **Testing de Reglas:**
```bash
# Verificar puerto SSH
nmap -p 22 localhost

# Verificar puertos web
nmap -p 80,443 localhost

# Verificar política por defecto
nmap -p 1-1000 localhost
```

## 📁 **Archivos Generados**

### **Scripts de Monitoreo:**
- `/usr/local/bin/ufw_monitor.sh` - Monitoreo automatizado
- `/var/log/ufw_monitor.log` - Logs de monitoreo

### **Backups:**
- `/var/backups/firewall/ufw_backup_YYYY-MM-DD/` - Backup de configuración

### **Configuración:**
- `/etc/ufw/` - Configuración principal de UFW
- `/var/log/ufw.log` - Logs del firewall

## 🔧 **Comandos de Gestión**

### **Gestión Manual:**
```bash
# Habilitar/Deshabilitar
sudo ufw enable
sudo ufw disable

# Agregar regla
sudo ufw allow 8080/tcp comment 'Custom service'

# Eliminar regla
sudo ufw delete allow 8080/tcp

# Resetear configuración
sudo ufw --force reset
```

### **Troubleshooting:**
```bash
# Verificar sintaxis
sudo ufw --dry-run enable

# Logs detallados
sudo ufw logging full

# Estado del servicio
sudo systemctl status ufw
```

## 📊 **Reglas por Defecto Configuradas**

| Puerto | Protocolo | Dirección | Comentario |
|--------|-----------|-----------|------------|
| 22 | TCP | IN | SSH Access (con rate limiting) |
| 80 | TCP | IN | HTTP Web Server |
| 443 | TCP | IN | HTTPS Web Server |
| 53 | UDP | OUT | DNS queries |
| 123 | UDP | OUT | NTP time sync |

## 🔐 **Integración con Vault**

El rol utiliza variables del vault para configuraciones sensibles:

```yaml
# En group_vars/all/vault.yml
vault_firewall_rules_backup_key: "clave_encriptacion_backup"
vault_admin_password: "password_administrador"
```

## ⚠️ **Consideraciones de Seguridad**

1. **SSH Rate Limiting:** Configurado automáticamente para prevenir ataques de fuerza bruta
2. **Política Restrictiva:** Por defecto bloquea todo tráfico entrante no autorizado
3. **Logging:** Configurable según necesidades (producción vs desarrollo)
4. **Monitoreo:** Alertas automáticas ante problemas de configuración
5. **Backup:** Respaldo automático antes de cambios importantes

## 🎓 **Cumplimiento Académico - Nivel 4**

### **Criterios Cumplidos:**
- ✅ **Configuración Avanzada:** Políticas personalizadas y reglas complejas
- ✅ **Automatización:** Configuración completamente automatizada
- ✅ **Monitoreo:** Sistema de alertas y logging avanzado
- ✅ **Seguridad:** Protección contra ataques comunes
- ✅ **Documentación:** Guía completa y casos de uso
- ✅ **Troubleshooting:** Comandos de diagnóstico y solución de problemas

### **Evidencias para Evaluación:**
1. Estado del firewall: `sudo ufw status verbose`
2. Logs de actividad: `sudo cat /var/log/ufw_monitor.log`
3. Reglas configuradas: `sudo ufw status numbered`
4. Script de monitoreo: `sudo cat /usr/local/bin/ufw_monitor.sh`

## 🔄 **Actualizaciones y Mantenimiento**

- **Backup Automático:** Antes de cada cambio de configuración
- **Monitoreo Continuo:** Verificación cada 10 minutos
- **Logs Rotados:** Configuración automática de logrotate
- **Alertas Proactivas:** Notificación inmediata de problemas

Este rol proporciona una base sólida de seguridad de red para el laboratorio, cumpliendo con todos los requisitos académicos de Nivel 4.