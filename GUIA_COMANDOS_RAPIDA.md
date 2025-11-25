# 🔧 GUÍA RÁPIDA DE COMANDOS POR COMPONENTE

## ⚡ Comandos de Ejecución Rápida

### **🚀 Implementación Completa (Un Solo Comando)**
```bash
# Ejecutar TODO el laboratorio de seguridad
ansible-playbook -i inventory/hosts.yml security_playbook.yml --ask-become-pass
```

---

## 🔒 SEGURIDAD LOCAL (Antivirus y Herramientas)

### **Ejecutar Solo Este Componente**
```bash
ansible-playbook -i inventory/hosts.yml security_playbook.yml --tags "antivirus,security" --ask-become-pass
```

### **Comandos de Verificación**
```bash
# En el host de destino:
sudo systemctl status clamav-daemon clamav-freshclam
sudo clamscan --version
sudo tail -f /var/log/clamav/clamav.log

# Ejecutar escaneo manual
sudo clamscan -r /home --infected --summary

# Ver programación de escaneos
sudo crontab -l | grep clam

# Ver base de datos de virus
sudo sigtool --info /var/lib/clamav/main.cvd
```

---

## 🛡️ PROTECCIÓN CONTRA AMENAZAS (IDS/IPS)

### **Ejecutar Solo Este Componente**
```bash
ansible-playbook -i inventory/hosts.yml security_playbook.yml --tags "ids,ips,threats" --ask-become-pass
```

### **Comandos de Verificación**
```bash
# Estado de Fail2Ban
sudo systemctl status fail2ban
sudo fail2ban-client status

# Ver cárceles específicas
sudo fail2ban-client status ssh
sudo fail2ban-client status apache

# Ver IPs baneadas actualmente
sudo fail2ban-client get ssh banned

# Desbanear IP específica (si es necesario)
sudo fail2ban-client set ssh unbanip 192.168.50.100

# Ver configuración activa
sudo cat /etc/fail2ban/jail.local

# Logs en tiempo real
sudo tail -f /var/log/fail2ban.log

# Estadísticas de AIDE (integridad)
sudo aide --check --verbose
sudo cat /var/log/aide/aide.log

# Auditoría del sistema (AUDITD)
sudo systemctl status auditd
sudo auditctl -l
sudo ausearch -k identity
```

---

## 👤 PRÁCTICAS SEGURAS DE USUARIO

### **Ejecutar Solo Este Componente**
```bash
ansible-playbook -i inventory/hosts.yml security_playbook.yml --tags "users,policies" --ask-become-pass
```

### **Comandos de Verificación**
```bash
# Verificar políticas de contraseñas
sudo cat /etc/login.defs | grep PASS

# Ver configuración de PAM
sudo cat /etc/pam.d/common-auth

# Verificar configuración SSH
sudo sshd -t
sudo cat /etc/ssh/sshd_config | grep -E "(Timeout|Allow|ClientAlive)"

# Ver configuración de sudo
sudo cat /etc/sudoers | grep -E "(logfile|requiretty|timestamp)"

# Verificar intentos de login fallidos
sudo grep "Failed password" /var/log/auth.log | tail -10

# Ver usuarios bloqueados
sudo pam_tally2 --user=testuser

# Verificar sesiones activas
who && last -n 5

# Ver configuración de umask
grep umask /etc/profile
```

---

## 🔥 FIREWALL (Protección Perimetral)

### **Ejecutar Solo Este Componente**
```bash
ansible-playbook -i inventory/hosts.yml security_playbook.yml --tags "firewall" --ask-become-pass
```

### **Comandos de Verificación**
```bash
# Estado del firewall
sudo ufw status verbose
sudo ufw status numbered

# Ver reglas de iptables subyacentes
sudo iptables -L -n -v

# Logs del firewall en tiempo real
sudo tail -f /var/log/ufw.log

# Verificar puertos abiertos
sudo netstat -tlnp
sudo ss -tlnp

# Probar conectividad específica
telnet 192.168.50.1 22
nc -zv 192.168.50.1 80

# Ver estadísticas de conexiones
sudo netstat -s
```

---

## 📊 MONITOREO Y REPORTES

### **Generar Reportes de Cumplimiento**
```bash
# Solo generar reportes
ansible-playbook -i inventory/hosts.yml security_playbook.yml --tags "reporting" --ask-become-pass

# Ver reportes generados
ls -la /var/log/security-compliance/
cat /var/log/security-compliance/compliance-$(date +%Y-%m-%d).txt
```

### **Comandos de Monitoreo en Tiempo Real**
```bash
# Dashboard de servicios de seguridad
watch 'sudo systemctl is-active clamav-daemon fail2ban auditd ufw ssh'

# Monitoreo de logs de seguridad
sudo multitail /var/log/auth.log /var/log/fail2ban.log /var/log/ufw.log

# Monitor de procesos de seguridad
watch 'ps aux | grep -E "(clam|fail2ban|audit)" | grep -v grep'

# Monitor de conexiones de red
watch 'sudo netstat -tupln | grep -E "(22|80|443)"'
```

---

## 🧪 COMANDOS DE PRUEBA Y TESTING

### **Probar Antivirus**
```bash
# Crear archivo de prueba EICAR (no es virus real)
echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > /tmp/eicar.txt

# Escanear archivo de prueba
sudo clamscan /tmp/eicar.txt
```

### **Probar IDS/IPS (Fail2Ban)**
```bash
# Simular ataques SSH (CUIDADO: puede bloquear tu IP)
# Ejecutar desde otra máquina:
for i in {1..10}; do ssh wronguser@192.168.50.1 2>/dev/null; sleep 1; done

# Verificar que la IP fue baneada
sudo fail2ban-client status ssh
```

### **Probar Auditoría**
```bash
# Generar eventos auditables
sudo touch /etc/test-audit-file
sudo rm /etc/test-audit-file

# Buscar eventos generados
sudo ausearch -f /etc/test-audit-file
```

### **Probar Integridad de Archivos**
```bash
# Modificar archivo monitorado
echo "test" | sudo tee -a /etc/passwd.backup > /dev/null

# Ejecutar verificación
sudo aide --check
```

---

## 🎯 COMANDOS PARA DEMOSTRACIÓN ACADÉMICA

### **Captura 1: Estado General del Sistema**
```bash
clear
echo "=== LABORATORIO DE SEGURIDAD - ESTADO GENERAL ==="
echo "Fecha: $(date)"
echo "Sistema: $(lsb_release -ds)"
echo "Kernel: $(uname -r)"
echo
echo "=== SERVICIOS DE SEGURIDAD ==="
sudo systemctl is-active clamav-daemon fail2ban auditd ufw ssh --quiet && echo "✅ Todos los servicios activos" || echo "❌ Algunos servicios inactivos"
```

### **Captura 2: Antivirus Funcionando**
```bash
clear
echo "=== DEMOSTRACIÓN: ANTIVIRUS CLAMAV ==="
echo "Estado del servicio:"
sudo systemctl status clamav-daemon --no-pager -l
echo
echo "Versión de la base de datos:"
sudo sigtool --info /var/lib/clamav/main.cvd | head -5
echo
echo "Último escaneo programado:"
sudo grep "FOUND\|SCAN SUMMARY" /var/log/clamav/clamav.log | tail -3
```

### **Captura 3: IDS/IPS Activo**
```bash
clear
echo "=== DEMOSTRACIÓN: IDS/IPS FAIL2BAN ==="
echo "Servicios de protección activos:"
sudo fail2ban-client status
echo
echo "Protección SSH específica:"
sudo fail2ban-client status ssh
echo
echo "Configuración de seguridad:"
sudo cat /etc/fail2ban/jail.local | grep -A5 "\[ssh\]"
```

### **Captura 4: Auditoría del Sistema**
```bash
clear
echo "=== DEMOSTRACIÓN: AUDITORÍA AUDITD ==="
echo "Estado del servicio de auditoría:"
sudo systemctl status auditd --no-pager -l
echo
echo "Reglas de auditoría activas:"
sudo auditctl -l
echo
echo "Últimos eventos de seguridad:"
sudo ausearch -k identity | tail -5
```

### **Captura 5: Firewall y Red**
```bash
clear
echo "=== DEMOSTRACIÓN: FIREWALL Y SEGURIDAD DE RED ==="
echo "Estado del firewall UFW:"
sudo ufw status verbose
echo
echo "Puertos abiertos en el sistema:"
sudo netstat -tlnp | grep LISTEN
echo
echo "Conexiones activas:"
sudo netstat -tn | grep ESTABLISHED | wc -l
echo "conexiones establecidas actualmente"
```

---

## 🚨 COMANDOS DE EMERGENCIA

### **Deshabilitar Temporalmente Seguridad** (Solo para desarrollo)
```bash
# CUIDADO: Solo usar en entorno de desarrollo
sudo systemctl stop fail2ban
sudo ufw disable
sudo systemctl stop auditd
```

### **Rehabilitar Seguridad**
```bash
# Reactivar todos los servicios
sudo systemctl start fail2ban auditd
sudo ufw enable
sudo systemctl restart clamav-daemon
```

### **Acceso de Emergencia SSH**
```bash
# Si quedaste bloqueado por Fail2Ban
# Desde consola local:
sudo fail2ban-client set ssh unbanip [TU_IP]

# O deshabilitar temporalmente
sudo fail2ban-client stop ssh
```

---

## 📱 COMANDOS DE UNA LÍNEA (Para Capturas Rápidas)

```bash
# Estado de seguridad completo
sudo systemctl status clamav-daemon fail2ban auditd ufw --no-pager | grep Active

# Resumen de protecciones activas
echo "🦠 Antivirus: $(sudo systemctl is-active clamav-daemon) | 🛡️ IDS/IPS: $(sudo systemctl is-active fail2ban) | 📋 Auditoría: $(sudo systemctl is-active auditd) | 🔥 Firewall: $(sudo ufw status | grep -o 'Status: [^[:space:]]*')"

# Último reporte de cumplimiento
cat /var/log/security-compliance/compliance-$(date +%Y-%m-%d).txt 2>/dev/null || echo "Reporte no encontrado - ejecutar playbook de seguridad"

# Estadísticas rápidas del sistema
echo "Sistema: $(hostname) | IP: $(hostname -I | awk '{print $1}') | Uptime: $(uptime -p) | Carga: $(uptime | awk -F'load average:' '{print $2}')"
```

---

*Guía de comandos para el laboratorio de seguridad - Noviembre 2025*