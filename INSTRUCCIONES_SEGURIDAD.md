# 🎯 EJECUCIÓN DEL LABORATORIO DE SEGURIDAD

## Pasos para Implementar la Seguridad Completa

### 1️⃣ Verificar Estructura del Proyecto

```bash
# Verificar que todos los roles están presentes
ls -la roles/
```

Deberías ver:
- `seguridad_local/` (antivirus, herramientas de seguridad)
- `proteccion_amenazas/` (IDS/IPS, monitoreo)
- `practicas_seguras_usuario/` (políticas de usuario)
- `usuarios_permisos/` (gestión de usuarios)
- `firewall/` (protección de red)

### 2️⃣ Ejecutar el Playbook de Seguridad

```bash
# Desde el directorio principal de Ansible
cd /home/jhonatan/ansible

# Ejecutar el playbook completo de seguridad
ansible-playbook -i inventory/hosts.ini security_playbook.yml --ask-become-pass

# O ejecutar en modo verbose para ver detalles
ansible-playbook -i inventory/hosts.ini security_playbook.yml --ask-become-pass -v
```

### 3️⃣ Verificar Implementación por Componentes

```bash
# Verificar solo el antivirus
ansible-playbook -i inventory/hosts.ini security_playbook.yml --tags "antivirus" --ask-become-pass

# Verificar solo IDS/IPS
ansible-playbook -i inventory/hosts.ini security_playbook.yml --tags "ids,ips" --ask-become-pass

# Verificar solo políticas de usuario
ansible-playbook -i inventory/hosts.ini security_playbook.yml --tags "users,policies" --ask-become-pass

# Verificar solo firewall
ansible-playbook -i inventory/hosts.ini security_playbook.yml --tags "firewall" --ask-become-pass
```

### 4️⃣ Validar Servicios de Seguridad

```bash
# En el sistema destino, verificar servicios activos
sudo systemctl status clamav-daemon
sudo systemctl status fail2ban
sudo systemctl status auditd
sudo systemctl status ssh
sudo ufw status

# Verificar logs de seguridad
sudo tail -f /var/log/security/auth.log
sudo tail -f /var/log/fail2ban.log
sudo tail -f /var/log/clamav/clamav.log
```

### 5️⃣ Verificar Cumplimiento Académico

```bash
# Revisar el reporte de cumplimiento generado
cat /var/log/security-compliance/compliance-$(date +%Y-%m-%d).txt

# Verificar configuraciones específicas
sudo cat /etc/fail2ban/jail.local
sudo cat /etc/aide/aide.conf
sudo crontab -l
```

## 🔍 Troubleshooting Común

### Si falla la instalación de ClamAV:
```bash
# Actualizar repositorios primero
sudo apt update
sudo apt install clamav clamav-daemon clamav-freshclam -y
```

### Si falla Fail2Ban:
```bash
# Verificar logs
sudo journalctl -u fail2ban -f
```

### Si falla la configuración SSH:
```bash
# Verificar sintaxis antes de reiniciar
sudo sshd -t
```

## ✅ Verificación Final

Una vez ejecutado exitosamente, deberías tener:

1. **🦠 Antivirus ClamAV** funcionando con escaneos automáticos
2. **🛡️ Fail2Ban** protegiendo contra ataques de fuerza bruta  
3. **📋 Sistema de auditoría** registrando actividad del sistema
4. **🔍 AIDE** verificando integridad de archivos críticos
5. **👤 Políticas de usuario** con timeouts y restricciones
6. **🔥 Firewall** configurado con reglas restrictivas
7. **📊 Monitoreo** de procesos y actividad

## 🏆 Cumplimiento Académico

Al completar estos pasos tendrás:
- **Unidad 2**: Nivel 4/4 ⭐⭐⭐⭐
- **Unidad 3**: Nivel 4/4 ⭐⭐⭐⭐

¡Tu laboratorio estará listo para la evaluación académica!