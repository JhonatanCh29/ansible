# 🚀 GUÍA DE IMPLEMENTACIÓN DESDE CERO - VM NUEVA

## 🎯 Implementación Completa del Laboratorio de Seguridad

Esta guía te permite implementar **todo el laboratorio** en una VM completamente nueva, desde la instalación hasta la verificación final.

---

## 📋 **PASO 0: REQUISITOS PREVIOS**

### **Especificaciones Mínimas de la VM**
- **Sistema Operativo**: Ubuntu Server 22.04 LTS o superior
- **RAM**: Mínimo 2GB (Recomendado 4GB)
- **Almacenamiento**: Mínimo 20GB libre
- **Red**: Acceso a internet para descargar paquetes
- **Usuario**: Con privilegios sudo

### **Información que Necesitas Tener Lista**
```bash
# Anota estos datos antes de comenzar:
IP_DE_TU_VM=192.168.50.X        # IP de tu nueva VM
USUARIO_VM=tu_usuario           # Tu usuario en la VM
CONTRASEÑA_ANSIBLE_VAULT=       # Contraseña que usarás para el vault (¡mínimo 12 caracteres!)
```

---

## 🔧 **PASO 1: PREPARACIÓN INICIAL DEL SISTEMA**

### **Conectarse a la VM Nueva**
```bash
# Desde tu máquina de control (puede ser otra VM o tu host)
ssh usuario@IP_DE_TU_VM

# O desde la consola directa de la VM
```

### **Actualizar el Sistema**
```bash
# Actualizar repositorios y paquetes
sudo apt update && sudo apt upgrade -y

# Instalar herramientas básicas
sudo apt install -y curl wget git tree vim htop net-tools

# Verificar que el sistema esté actualizado
lsb_release -a
```

### **Configurar Hostname (Opcional pero Recomendado)**
```bash
# Cambiar el nombre del host para identificarlo mejor
sudo hostnamectl set-hostname lab-security-vm

# Verificar el cambio
hostnamectl status
```

---

## 📥 **PASO 2: INSTALACIÓN DE ANSIBLE**

### **Instalar Python y pip**
```bash
# Instalar Python 3 y pip
sudo apt install -y python3 python3-pip python3-venv

# Verificar instalación
python3 --version
pip3 --version
```

### **Instalar Ansible**
```bash
# Instalar Ansible desde los repositorios oficiales
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# Verificar instalación
ansible --version

# Debe mostrar algo como: ansible [core 2.19.x]
```

### **Configurar SSH para Ansible**
```bash
# Generar clave SSH para Ansible (si no tienes una)
ssh-keygen -t rsa -b 4096 -C "ansible@$(hostname)" -f ~/.ssh/id_rsa -N ""

# Agregar la clave pública a authorized_keys para conexión local
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Probar conexión SSH local
ssh -o StrictHostKeyChecking=no localhost 'echo "SSH funcionando correctamente"'
```

---

## 📂 **PASO 3: CLONAR EL REPOSITORIO**

### **Clonar el Proyecto desde GitHub**
```bash
# Ir al directorio home
cd ~

# Clonar el repositorio del laboratorio
git clone https://github.com/JhonatanCh29/ansible.git

# Entrar al directorio del proyecto
cd ansible

# Verificar contenido
ls -la
tree -L 2 roles/
```

### **Verificar Estructura del Proyecto**
```bash
# Mostrar estructura completa
echo "📂 ESTRUCTURA DEL PROYECTO:"
echo "=========================="
tree -a -I '.git' -L 3

echo -e "\n🔧 ARCHIVOS DE CONFIGURACIÓN:"
echo "============================="
ls -la *.cfg *.yml

echo -e "\n👥 ROLES DISPONIBLES:"
echo "===================="
ls -la roles/
```

---

## ⚙️ **PASO 4: CONFIGURACIÓN INICIAL**

### **Verificar Configuración de Ansible**
```bash
# Ver configuración actual
ansible-config view

# Verificar inventario
cat inventory/hosts.yml

# Probar sintaxis del inventario
ansible-inventory --list -i inventory/hosts.yml
```

### **Adaptar Inventario para VM Local**
```bash
# Crear inventario para ejecución local
cat > inventory/local_hosts.yml << EOF
---
# Inventario para ejecución en VM local
local_lab:
  hosts:
    localhost:
      ansible_connection: local
      ansible_host: 127.0.0.1
      ansible_user: $USER
      
  vars:
    ansible_become: true
    ansible_become_method: sudo
    ansible_python_interpreter: /usr/bin/python3

all:
  vars:
    # Configuración para laboratorio local
    lan_gateway_ip: "127.0.0.1"
    lan_interface: "lo"
    admin_user: "$USER"
EOF

# Verificar inventario local
ansible-inventory --list -i inventory/local_hosts.yml
```

### **Probar Conectividad con Ansible**
```bash
# Probar conexión local
ansible all -i inventory/local_hosts.yml -m ping

# Debe responder: localhost | SUCCESS => {"ping": "pong"}

# Probar ejecución de comandos
ansible all -i inventory/local_hosts.yml -m shell -a "whoami"
ansible all -i inventory/local_hosts.yml -m shell -a "hostname" --become
```

---

## 🔐 **PASO 5: CONFIGURACIÓN DEL VAULT (SEGURIDAD)**

### **Configurar Variables Seguras**
```bash
# Ejecutar script de configuración del vault
chmod +x scripts/setup_vault.sh

# Ejecutar configuración automática
./scripts/setup_vault.sh

# Si prefieres configuración manual:
```

### **Configuración Manual del Vault (Alternativa)**
```bash
# Crear contraseña del vault
echo "TuContraseñaSeguraAqui123!" > .vault_pass
chmod 600 .vault_pass

# Encriptar archivo vault
ansible-vault encrypt group_vars/all/vault.yml --vault-password-file .vault_pass

# Verificar que esté encriptado
head -5 group_vars/all/vault.yml

# Debe mostrar: $ANSIBLE_VAULT;1.1;AES256
```

---

## 🚀 **PASO 6: EJECUCIÓN DE LA IMPLEMENTACIÓN COMPLETA**

### **Opción A: Implementación Completa (Recomendada)**
```bash
# Ejecutar todo el sistema de seguridad
ansible-playbook -i inventory/local_hosts.yml security_playbook.yml \
  --vault-password-file .vault_pass \
  --ask-become-pass

# El sistema pedirá tu contraseña de sudo
```

### **Opción B: Implementación por Componentes**
```bash
# Solo usuarios y permisos
ansible-playbook -i inventory/local_hosts.yml security_playbook.yml \
  --tags "users,groups,permissions" \
  --vault-password-file .vault_pass \
  --ask-become-pass

# Solo seguridad (antivirus, IDS/IPS)
ansible-playbook -i inventory/local_hosts.yml security_playbook.yml \
  --tags "antivirus,security,ids,ips" \
  --vault-password-file .vault_pass \
  --ask-become-pass

# Solo firewall
ansible-playbook -i inventory/local_hosts.yml security_playbook.yml \
  --tags "firewall" \
  --vault-password-file .vault_pass \
  --ask-become-pass

# Solo monitoreo y auditoría
ansible-playbook -i inventory/local_hosts.yml security_playbook.yml \
  --tags "monitoring,auditd" \
  --vault-password-file .vault_pass \
  --ask-become-pass
```

### **Verificar Ejecución**
```bash
# Ver logs de la ejecución
tail -f ansible.log  # Si existe

# O ver salida en tiempo real con verbose
ansible-playbook -i inventory/local_hosts.yml security_playbook.yml \
  --vault-password-file .vault_pass \
  --ask-become-pass \
  -v
```

---

## 🔍 **PASO 7: VERIFICACIÓN DE LA IMPLEMENTACIÓN**

### **Verificar Servicios de Seguridad**
```bash
echo "🔍 VERIFICANDO SERVICIOS DE SEGURIDAD..."
echo "======================================="

# Verificar estado de todos los servicios
sudo systemctl status clamav-daemon fail2ban auditd ufw ssh --no-pager

# Verificar procesos activos
ps aux | grep -E "(clam|fail2ban|audit)" | grep -v grep

# Verificar puertos abiertos
sudo netstat -tlnp | grep LISTEN
```

### **Verificar Gestión de Usuarios**
```bash
echo "👥 VERIFICANDO GESTIÓN DE USUARIOS..."
echo "===================================="

# Ver usuarios del laboratorio
getent passwd | grep lab_

# Ver grupos del laboratorio  
getent group | grep -E "(admin_users|developers|operators|backup_users|audit_users)"

# Ver directorios compartidos
ls -la /home/shared/ 2>/dev/null || echo "Directorios compartidos no creados aún"

# Ejecutar reporte de usuarios
sudo /usr/local/bin/lab-users-report 2>/dev/null || echo "Script de reporte no disponible aún"
```

### **Verificar Configuración de Seguridad**
```bash
echo "🔐 VERIFICANDO CONFIGURACIÓN DE SEGURIDAD..."
echo "==========================================="

# Estado del firewall
sudo ufw status verbose

# Configuración de Fail2Ban
sudo fail2ban-client status 2>/dev/null || echo "Fail2Ban no configurado aún"

# Verificar auditoría
sudo auditctl -l 2>/dev/null || echo "Auditoría no configurada aún"

# Verificar antivirus
clamscan --version 2>/dev/null || echo "ClamAV no instalado aún"
```

---

## ✅ **PASO 8: VERIFICACIÓN FINAL Y REPORTES**

### **Dashboard de Estado Completo**
```bash
# Crear script de verificación completa
cat > /tmp/verificar_laboratorio.sh << 'EOF'
#!/bin/bash

echo "═══════════════════════════════════════════════════════════════"
echo "🏆 VERIFICACIÓN FINAL DEL LABORATORIO DE SEGURIDAD"
echo "═══════════════════════════════════════════════════════════════"
echo "📅 $(date)"
echo "🖥️  Sistema: $(lsb_release -ds)"
echo "🏠 Host: $(hostname)"
echo ""

echo "🔒 SERVICIOS DE SEGURIDAD:"
echo "─────────────────────────"
services=("clamav-daemon" "fail2ban" "auditd" "ufw" "ssh")
for service in "${services[@]}"; do
    status=$(systemctl is-active $service 2>/dev/null || echo "inactive")
    if [ "$status" = "active" ]; then
        echo "  ✅ $service: ACTIVO"
    else
        echo "  ❌ $service: $status"
    fi
done

echo ""
echo "👥 USUARIOS Y GRUPOS:"
echo "────────────────────"
users_count=$(getent passwd | grep lab_ | wc -l)
groups_count=$(getent group | grep -E "(admin_users|developers|operators)" | wc -l)
echo "  👤 Usuarios del laboratorio: $users_count"
echo "  👥 Grupos funcionales: $groups_count"

echo ""
echo "📁 DIRECTORIOS:"
echo "──────────────"
if [ -d "/home/shared" ]; then
    shared_dirs=$(find /home/shared -maxdepth 1 -type d | wc -l)
    echo "  📂 Directorios compartidos: $((shared_dirs-1))"
    ls /home/shared/ | sed 's/^/    /'
else
    echo "  📂 Directorios compartidos: No configurados"
fi

echo ""
echo "🔧 CONFIGURACIONES:"
echo "──────────────────"
[ -f /etc/sudoers.d/lab-users ] && echo "  ✅ Configuración sudo: OK" || echo "  ❌ Configuración sudo: Faltante"
[ -f /etc/fail2ban/jail.local ] && echo "  ✅ Configuración Fail2Ban: OK" || echo "  ❌ Configuración Fail2Ban: Faltante"
[ -f /etc/aide/aide.conf ] && echo "  ✅ Configuración AIDE: OK" || echo "  ❌ Configuración AIDE: Faltante"

echo ""
echo "📊 RESUMEN:"
echo "──────────"
active_services=$(systemctl is-active clamav-daemon fail2ban auditd ufw ssh 2>/dev/null | grep -c "active")
echo "  🔒 Servicios activos: $active_services/5"
echo "  👥 Gestión de usuarios: $([ $users_count -ge 3 ] && echo "✅ Configurada" || echo "❌ Pendiente")"
echo "  🔐 Seguridad: $([ $active_services -ge 3 ] && echo "✅ Operativa" || echo "⚠️  Parcial")"

echo ""
if [ $active_services -ge 3 ] && [ $users_count -ge 3 ]; then
    echo "🎉 LABORATORIO IMPLEMENTADO EXITOSAMENTE"
    echo "✅ Listo para demostración académica"
else
    echo "⚠️  IMPLEMENTACIÓN PARCIAL"
    echo "❓ Revisar logs y ejecutar playbooks nuevamente"
fi
echo "═══════════════════════════════════════════════════════════════"
EOF

chmod +x /tmp/verificar_laboratorio.sh
/tmp/verificar_laboratorio.sh
```

### **Generar Reporte de Cumplimiento Académico**
```bash
# Ver reporte de compliance si existe
cat /var/log/security-compliance/compliance-$(date +%Y-%m-%d).txt 2>/dev/null || echo "Reporte de compliance no generado aún"

# Ver reporte de usuarios si existe  
cat /var/log/lab-users/implementation-$(date +%Y-%m-%d).txt 2>/dev/null || echo "Reporte de usuarios no generado aún"
```

---

## 🎯 **COMANDOS RÁPIDOS PARA DEMOSTRACIÓN**

### **Demo Rápida del Sistema**
```bash
# Mostrar estructura del proyecto
clear && tree ~/ansible -L 2 -a

# Mostrar servicios activos
clear && sudo systemctl status clamav-daemon fail2ban auditd ufw --no-pager | grep Active

# Mostrar usuarios creados
clear && echo "👥 USUARIOS DEL LABORATORIO:" && getent passwd | grep lab_

# Mostrar grupos creados
clear && echo "👥 GRUPOS FUNCIONALES:" && getent group | grep -E "(admin_users|developers|operators)"

# Estado del firewall
clear && sudo ufw status verbose

# Dashboard completo
clear && /tmp/verificar_laboratorio.sh
```

---

## 🚨 **SOLUCIÓN DE PROBLEMAS COMUNES**

### **Si Ansible No Se Conecta**
```bash
# Verificar SSH
ssh localhost whoami

# Verificar configuración de Ansible
ansible-config dump | grep inventory

# Probar conexión específica
ansible all -i inventory/local_hosts.yml -m ping -vvv
```

### **Si Fallan las Instalaciones**
```bash
# Actualizar cache de apt
sudo apt update

# Verificar espacio en disco
df -h

# Verificar logs del sistema
sudo journalctl -f

# Ejecutar con más verbosidad
ansible-playbook security_playbook.yml -vvv
```

### **Si los Servicios No Inician**
```bash
# Ver logs específicos
sudo journalctl -u clamav-daemon -f
sudo journalctl -u fail2ban -f

# Verificar configuraciones
sudo clamav-testfiles
sudo fail2ban-client -t
```

---

## 🏁 **RESULTADO ESPERADO**

Al completar esta guía tendrás:

✅ **VM completamente configurada** con Ansible  
✅ **Laboratorio de seguridad operativo** con todos los componentes  
✅ **5 usuarios especializados** con permisos diferenciados  
✅ **Servicios de seguridad activos** (antivirus, IDS/IPS, firewall)  
✅ **Sistema de auditoría funcionando** con logs centralizados  
✅ **Herramientas de administración** y reportes automáticos  
✅ **Cumplimiento académico Nivel 4** en ambas unidades  

### **Comandos de Verificación Final**
```bash
# Comando todo-en-uno para verificar el estado
echo "🎯 ESTADO FINAL DEL LABORATORIO:" && \
sudo systemctl is-active clamav-daemon fail2ban auditd ufw && \
echo "👥 Usuarios: $(getent passwd | grep -c lab_)" && \
echo "🏆 IMPLEMENTACIÓN COMPLETADA"
```

---

**🚀 ¡Tu laboratorio de seguridad estará listo para evaluación académica!** 

*Tiempo estimado de implementación: 15-30 minutos dependiendo de la velocidad de la VM*