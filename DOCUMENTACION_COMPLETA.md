# 📚 DOCUMENTACIÓN COMPLETA - LABORATORIO DE SEGURIDAD CON ANSIBLE

## 🎯 Descripción del Proyecto

Este proyecto implementa un **laboratorio de seguridad integral** usando Ansible para automatizar la configuración de sistemas de seguridad en un entorno virtualizado ESXi. Cumple con los requisitos académicos de **Nivel 4** para las Unidades 2 y 3.

---

## 🏗️ Arquitectura del Laboratorio

### **Infraestructura Virtual**
- **ESXi Server**: `172.17.25.03`
- **Red LAN**: `192.168.50.0/24` (PSwitch_Jhona)
- **Red WAN**: Acceso a internet (VM Network)

### **Máquinas Virtuales**
| Host | IP | Rol | Sistema |
|------|----|----|---------|
| `vm_jhonatan` | `192.168.50.1` | Gateway/DHCP/DNS | Ubuntu Server |
| `mint_jhonatan` | `192.168.50.100` | Cliente de pruebas | Linux Mint |
| `control_ansible` | `192.168.50.10` | Nodo de control | Ubuntu Server |

---

## 🔧 Instalación y Configuración Inicial

### **1. Clonar el Repositorio**
```bash
# En el nodo de control de Ansible
git clone https://github.com/JhonatanCh29/ansible.git
cd ansible
```

### **2. Verificar Estructura del Proyecto**
```bash
# Mostrar estructura completa
tree -a

# Verificar roles de seguridad
ls -la roles/

# Verificar configuración
cat ansible.cfg
```

### **3. Configurar Python y Ansible**
```bash
# Instalar dependencias
sudo apt update && sudo apt install ansible python3-pip tree -y

# Verificar versión de Ansible
ansible --version

# Configurar Python para el workspace
./scripts/setup_vault.sh  # Opcional: para configurar vault con claves reales
```

---

## 🔐 Configuración de Seguridad (Ansible Vault)

### **Ver Variables de Seguridad**
```bash
# Ver configuración de seguridad (sin encriptar)
cat group_vars/all/security.yml

# Ver variables del vault (template)
cat group_vars/all/vault.yml
```

### **Configurar Vault con Claves Reales** (Opcional)
```bash
# Ejecutar script automático
./scripts/setup_vault.sh

# O configurar manualmente
ansible-vault create group_vars/all/vault_real.yml
ansible-vault edit group_vars/all/vault_real.yml
```

### **Comandos de Vault**
```bash
# Ver contenido encriptado
ansible-vault view group_vars/all/vault.yml

# Editar vault encriptado
ansible-vault edit group_vars/all/vault.yml

# Encriptar archivo existente
ansible-vault encrypt group_vars/all/vault.yml

# Cambiar contraseña del vault
ansible-vault rekey group_vars/all/vault.yml
```

---

## 📋 Verificación del Inventario

### **Validar Inventario YAML**
```bash
# Verificar sintaxis del inventario
ansible-inventory --list -i inventory/hosts.yml

# Listar todos los hosts
ansible all --list-hosts

# Verificar conectividad (requiere SSH configurado)
ansible all -m ping

# Información detallada de un host específico
ansible vm_jhonatan -m setup
```

### **Verificar Configuración**
```bash
# Ver configuración completa de Ansible
ansible-config dump

# Verificar archivo de configuración
ansible-config view

# Validar sintaxis de playbooks
ansible-playbook --syntax-check security_playbook.yml
```

---

## 🚀 Ejecución de Playbooks de Seguridad

### **Playbook Principal (Seguridad Completa)**
```bash
# Ejecutar implementación completa de seguridad
ansible-playbook -i inventory/hosts.yml security_playbook.yml --ask-become-pass

# Con modo verbose para ver detalles
ansible-playbook -i inventory/hosts.yml security_playbook.yml --ask-become-pass -v

# Verificar solo sintaxis sin ejecutar
ansible-playbook --syntax-check security_playbook.yml
```

### **Playbooks por Componentes (Tags)**
```bash
# Solo antivirus y herramientas locales
ansible-playbook -i inventory/hosts.yml security_playbook.yml --tags "antivirus,security" --ask-become-pass

# Solo IDS/IPS y protección de amenazas
ansible-playbook -i inventory/hosts.yml security_playbook.yml --tags "ids,ips,threats" --ask-become-pass

# Solo firewall
ansible-playbook -i inventory/hosts.yml security_playbook.yml --tags "firewall" --ask-become-pass

# Solo gestión de usuarios y permisos
ansible-playbook -i inventory/hosts.yml security_playbook.yml --tags "users,groups,permissions" --ask-become-pass

# Solo políticas de usuario avanzadas
ansible-playbook -i inventory/hosts.yml security_playbook.yml --tags "users,policies" --ask-become-pass

# Solo monitoreo y auditoría
ansible-playbook -i inventory/hosts.yml security_playbook.yml --tags "monitoring,auditd" --ask-become-pass
```

### **Playbooks Específicos**
```bash
# Configuración inicial del nodo de control
ansible-playbook playbooks/bootstrap_control.yml

# Gestión completa de usuarios (Nivel 4)
ansible-playbook playbooks/manage_users.yml --ask-become-pass

# Verificar estado del firewall
ansible-playbook playbooks/verificar_firewall.yml

# Deshabilitar firewall temporalmente (desarrollo)
ansible-playbook playbooks/disable_firewall.yml
```

---

## 🔍 Verificación de Servicios de Seguridad

### **En los Hosts de Destino**

#### **1. Verificar Antivirus (ClamAV)**
```bash
# Estado del servicio
sudo systemctl status clamav-daemon

# Verificar logs de ClamAV
sudo tail -f /var/log/clamav/clamav.log

# Ejecutar escaneo manual
sudo clamscan -r /home --log=/tmp/scan.log

# Ver definiciones de virus
sudo freshclam
```

#### **2. Verificar IDS/IPS (Fail2Ban)**
```bash
# Estado del servicio
sudo systemctl status fail2ban

# Ver cárceles activas
sudo fail2ban-client status

# Ver IPs baneadas en SSH
sudo fail2ban-client status ssh

# Logs de Fail2Ban
sudo tail -f /var/log/fail2ban.log
```

#### **3. Verificar Auditoría (AUDITD)**
```bash
# Estado del servicio
sudo systemctl status auditd

# Ver reglas de auditoría activas
sudo auditctl -l

# Buscar eventos de auditoría
sudo ausearch -k identity

# Ver logs de auditoría
sudo tail -f /var/log/audit/audit.log
```

#### **4. Verificar Integridad (AIDE)**
```bash
# Inicializar base de datos AIDE
sudo aide --init

# Ejecutar verificación de integridad
sudo aide --check

# Ver configuración AIDE
sudo cat /etc/aide/aide.conf
```

#### **5. Verificar Firewall (UFW)**
```bash
# Estado del firewall
sudo ufw status verbose

# Ver reglas numeradas
sudo ufw status numbered

# Ver logs del firewall
sudo tail -f /var/log/ufw.log
```

---

## 📊 Comandos de Monitoreo y Verificación

### **Estado General del Sistema**
```bash
# Servicios de seguridad críticos
sudo systemctl status clamav-daemon fail2ban auditd ssh ufw

# Procesos de seguridad ejecutándose
ps aux | grep -E "(clam|fail2ban|audit)"

# Usuarios conectados al sistema
who && last -n 10

# Intentos de login fallidos
sudo grep "Failed password" /var/log/auth.log | tail -10
```

### **Verificación de Archivos de Configuración**
```bash
# Configuración SSH segura
sudo sshd -t && echo "SSH config OK"

# Configuración de sudo
sudo visudo -c && echo "Sudoers config OK"

# Verificar configuración de Fail2Ban
sudo fail2ban-client -t

# Verificar sintaxis de AIDE
sudo aide --config-check
```

### **Logs Importantes de Seguridad**
```bash
# Logs de autenticación
sudo tail -f /var/log/auth.log

# Logs de seguridad personalizados
sudo tail -f /var/log/security/auth.log

# Logs del kernel (para firewall)
sudo dmesg | grep -i firewall

# Logs de sistema general
sudo tail -f /var/log/syslog
```

---

## 🎯 Validación del Cumplimiento Académico

### **Verificar Reportes de Cumplimiento**
```bash
# Ver reporte generado automáticamente
cat /var/log/security-compliance/compliance-$(date +%Y-%m-%d).txt

# Listar todos los reportes
ls -la /var/log/security-compliance/

# Generar reporte manual
ansible-playbook security_playbook.yml --tags "reporting" --ask-become-pass
```

### **Comandos para Demostración Académica**

#### **Nivel 4 - Unidad 2 (Configuración de Red)**
```bash
# Verificar DHCP activo
sudo systemctl status isc-dhcp-server

# Ver clientes DHCP conectados
sudo dhcp-lease-list

# Verificar NAT/forwarding
cat /proc/sys/net/ipv4/ip_forward

# Ver tabla de enrutamiento
ip route show
```

#### **Nivel 4 - Unidad 3 (Seguridad del Sistema)**
```bash
# Demostrar antivirus funcionando
sudo clamscan /tmp --infected --summary

# Mostrar protección contra ataques
sudo fail2ban-client status ssh

# Demostrar auditoría del sistema
sudo ausearch -sc execve | tail -5

# Verificar integridad de archivos críticos
sudo aide --check | grep -E "(added|removed|changed)"

# Mostrar políticas de usuario activas
sudo cat /etc/pam.d/common-auth | grep tally
```

---

## 🛠️ Troubleshooting Común

### **Problemas de Conectividad**
```bash
# Verificar conectividad SSH
ansible all -m ping

# Probar conexión específica
ssh -vvv jhonatan@192.168.50.1

# Verificar llaves SSH
ssh-add -l
```

### **Problemas de Servicios**
```bash
# Reiniciar servicio específico
sudo systemctl restart clamav-daemon

# Ver logs de errores
sudo journalctl -u fail2ban -f

# Verificar puertos abiertos
sudo netstat -tlnp
```

### **Problemas de Ansible**
```bash
# Verificar configuración
ansible-config dump | grep -i inventory

# Ejecutar en modo debug
ansible-playbook security_playbook.yml -vvv

# Verificar variables
ansible-inventory --host vm_jhonatan
```

---

## 📈 Comandos de Rendimiento y Optimización

### **Monitoreo de Recursos**
```bash
# CPU y memoria
htop

# Espacio en disco
df -h

# Procesos de seguridad
ps aux --sort=-%cpu | head -10

# Conexiones de red
sudo netstat -tupln
```

### **Optimización**
```bash
# Limpiar logs antiguos
sudo journalctl --vacuum-time=7d

# Optimizar base de datos de ClamAV
sudo freshclam

# Verificar y reparar AIDE
sudo aide --update
```

---

## 🎉 Comandos para Capturas Académicas

### **Para Presentaciones y Documentación**
```bash
# Estructura del proyecto
tree -a -I '.git' | head -30

# Estado completo de servicios
sudo systemctl status clamav-daemon fail2ban auditd ufw --no-pager

# Resumen de seguridad en una pantalla
echo "=== ESTADO DE SEGURIDAD ===" && \
sudo ufw status && \
echo -e "\n=== SERVICIOS ACTIVOS ===" && \
sudo systemctl is-active clamav-daemon fail2ban auditd

# Información del sistema para reportes
echo "Sistema: $(lsb_release -d | cut -f2)" && \
echo "Kernel: $(uname -r)" && \
echo "Ansible: $(ansible --version | head -1)"
```

---

## 🏆 Resultados Esperados

Al completar la ejecución exitosa, tendrás:

✅ **Sistema antivirus activo** con escaneos programados  
✅ **Protección IDS/IPS** contra ataques de fuerza bruta  
✅ **Auditoría completa** del sistema  
✅ **Verificación de integridad** de archivos críticos  
✅ **Políticas de usuario** avanzadas implementadas  
✅ **Firewall** configurado con reglas restrictivas  
✅ **Monitoreo** en tiempo real de la actividad del sistema  

### **Cumplimiento Académico Verificado:**
- **Unidad 2**: ⭐⭐⭐⭐ Nivel 4 - Configuración avanzada de red
- **Unidad 3**: ⭐⭐⭐⭐ Nivel 4 - Seguridad integral del sistema

---

## 📞 Contacto y Soporte

**Desarrollador**: Jhonatan Ch  
**Repositorio**: https://github.com/JhonatanCh29/ansible  
**Tag Release**: v2.0-security-complete  

Para reportar problemas o mejoras, crear un issue en el repositorio de GitHub.

---

*Documentación generada para el laboratorio académico de seguridad - Noviembre 2025*