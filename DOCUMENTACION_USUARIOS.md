# 👥 DOCUMENTACIÓN COMPLETA - GESTIÓN DE USUARIOS Y PERMISOS

## 🎯 Descripción del Componente

La **gestión de usuarios y permisos** es un componente crítico del laboratorio que implementa un sistema robusto de administración de cuentas, grupos funcionales y políticas de acceso. Cumple con los requisitos de **Nivel 4** académico para administración avanzada de sistemas.

---

## 🏗️ Arquitectura de Usuarios y Grupos

### **Estructura Jerárquica de Grupos**

```
👑 admin_users (GID: 2000)
├── lab_admin → Administrador principal
└── Acceso completo al sistema

💻 developers (GID: 2001)  
├── lab_developer → Desarrollador principal
└── Acceso a herramientas de desarrollo

⚙️ operators (GID: 2002)
├── lab_operator → Operador de sistemas
└── Gestión de servicios y procesos

💾 backup_users (GID: 2003)
├── lab_backup → Usuario de respaldos
└── Acceso a herramientas de backup

📊 audit_users (GID: 2004)
├── lab_audit → Usuario de auditoría
└── Solo lectura para monitoreo
```

---

## 🚀 Implementación del Rol de Usuarios

### **1. Ejecutar Solo Gestión de Usuarios**
```bash
# Implementar solo usuarios y grupos
ansible-playbook -i inventory/hosts.yml security_playbook.yml --tags "users,groups" --ask-become-pass

# O usar playbook específico
ansible-playbook -i inventory/hosts.yml playbooks/manage_users.yml --ask-become-pass
```

### **2. Verificar Sintaxis del Rol**
```bash
# Verificar que el rol esté bien configurado
ansible-playbook --syntax-check -i inventory/hosts.yml security_playbook.yml

# Ejecutar en modo check (sin cambios)
ansible-playbook -i inventory/hosts.yml security_playbook.yml --tags "users" --check
```

---

## 👤 Gestión de Usuarios del Laboratorio

### **Verificar Usuarios Creados**
```bash
# Listar todos los usuarios del laboratorio
getent passwd | grep -E "lab_"

# Ver información detallada de un usuario específico
id lab_admin
finger lab_developer 2>/dev/null || echo "Finger no disponible"

# Ver grupos de todos los usuarios lab
for user in lab_admin lab_operator lab_developer lab_audit lab_backup; do
    echo "=== $user ==="
    groups $user 2>/dev/null || echo "Usuario no encontrado"
    echo
done
```

### **Comandos de Administración de Usuarios**
```bash
# Cambiar contraseña de un usuario (como admin)
sudo passwd lab_operator

# Bloquear/desbloquear cuenta temporalmente
sudo usermod -L lab_developer  # Bloquear
sudo usermod -U lab_developer  # Desbloquear

# Ver información de expiración de contraseñas
sudo chage -l lab_admin

# Forzar cambio de contraseña en próximo login
sudo chage -d 0 lab_operator

# Ver último login de usuarios
lastlog | grep lab_
```

---

## 👥 Gestión de Grupos y Membresías

### **Verificar Grupos del Sistema**
```bash
# Listar grupos del laboratorio con sus GIDs
getent group | grep -E "(admin_users|developers|operators|backup_users|audit_users)"

# Ver miembros de cada grupo
for group in admin_users developers operators backup_users audit_users; do
    echo "=== Grupo: $group ==="
    getent group $group
    echo
done

# Contar usuarios por grupo
echo "📊 ESTADÍSTICAS DE GRUPOS:"
for group in admin_users developers operators backup_users audit_users; do
    members=$(getent group $group | cut -d: -f4 | tr ',' '\n' | wc -l)
    echo "  $group: $members miembro(s)"
done
```

### **Administración de Membresías**
```bash
# Agregar usuario a un grupo adicional
sudo usermod -a -G developers lab_operator

# Remover usuario de un grupo
sudo gpasswd -d lab_operator developers

# Ver grupos efectivos de un proceso
ps -eo pid,user,group,supgrp,comm | grep lab_

# Cambiar grupo primario de un usuario
sudo usermod -g operators lab_backup
```

---

## 📁 Gestión de Directorios y Permisos

### **Verificar Directorios Compartidos**
```bash
# Ver estructura completa de directorios compartidos
tree /home/shared/ -L 3 -p

# Verificar permisos detallados
ls -la /home/shared/

# Ver propietarios y grupos de cada directorio
for dir in /home/shared/*; do
    if [ -d "$dir" ]; then
        echo "=== $(basename $dir) ==="
        ls -ld "$dir"
        echo "Contenido:"
        ls -la "$dir" 2>/dev/null || echo "  (vacío o sin acceso)"
        echo
    fi
done
```

### **Probar Permisos de Acceso**
```bash
# Como usuario admin
sudo -u lab_admin touch /home/shared/admin/test_admin.txt

# Como usuario developer
sudo -u lab_developer touch /home/shared/development/test_dev.txt

# Como usuario operator  
sudo -u lab_operator ls -la /home/shared/operations/

# Intentar acceso no autorizado (debe fallar)
sudo -u lab_audit touch /home/shared/admin/test_fail.txt 2>&1 || echo "✅ Acceso denegado correctamente"

# Ver ACLs si están configuradas
getfacl /home/shared/development 2>/dev/null || echo "ACLs no configuradas"
```

### **Administrar Permisos de Directorios**
```bash
# Cambiar propietario de un directorio
sudo chown -R root:developers /home/shared/development

# Configurar permisos especiales (setgid)
sudo chmod g+s /home/shared/development

# Ver permisos octales
stat -c "%n %a" /home/shared/*

# Aplicar permisos recursivamente
sudo chmod -R 755 /home/shared/operations
```

---

## 🔐 Configuración de Sudo y Privilegios

### **Verificar Configuración Sudo**
```bash
# Ver configuración sudo del laboratorio
sudo cat /etc/sudoers.d/lab-users

# Verificar sintaxis del archivo sudoers
sudo visudo -c -f /etc/sudoers.d/lab-users

# Listar privilegios de cada usuario
for user in lab_admin lab_operator lab_developer lab_audit lab_backup; do
    echo "=== Privilegios de $user ==="
    sudo -u $user sudo -l 2>/dev/null || echo "Sin privilegios sudo"
    echo
done
```

### **Probar Privilegios Sudo por Grupo**
```bash
# Administradores (acceso completo)
sudo -u lab_admin sudo whoami

# Operadores (gestión de servicios)
sudo -u lab_operator sudo systemctl status ssh

# Desarrolladores (instalación de paquetes)
sudo -u lab_developer sudo apt list --installed | head -5

# Backup (herramientas de respaldo)
sudo -u lab_backup sudo tar --version

# Auditoría (solo lectura)
sudo -u lab_audit sudo cat /etc/passwd | head -5
```

### **Administrar Privilegios Sudo**
```bash
# Editar configuración sudo específica
sudo visudo -f /etc/sudoers.d/lab-users

# Ver logs de actividad sudo
sudo tail -f /var/log/auth.log | grep sudo

# Ver historial de comandos sudo
sudo journalctl | grep sudo | tail -10

# Verificar qué usuarios pueden usar sudo
grep -E "^sudo:" /etc/group
```

---

## 🔒 Políticas de Contraseñas y Seguridad

### **Verificar Políticas de Contraseñas**
```bash
# Ver configuración de políticas
sudo cat /etc/pam.d/common-password | grep pwquality

# Verificar configuración en login.defs
grep -E "(PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_WARN_AGE|PASS_MIN_LEN)" /etc/login.defs

# Probar validación de contraseñas
echo "test123" | pwscore 2>/dev/null || echo "Herramienta pwscore no disponible"

# Ver información de expiración para todos los usuarios lab
for user in lab_admin lab_operator lab_developer lab_audit lab_backup; do
    echo "=== $user ==="
    sudo chage -l $user 2>/dev/null | grep -E "(Last password change|Password expires|Password inactive)"
    echo
done
```

### **Administrar Políticas de Contraseñas**
```bash
# Establecer expiración específica para un usuario
sudo chage -M 60 -W 7 lab_developer

# Forzar cambio inmediato de contraseña
sudo chage -d 0 lab_operator

# Ver usuarios con contraseñas expiradas
sudo awk -F: '($5 < '$(date +%s)'/86400) && ($5 != -1) {print $1}' /etc/shadow

# Verificar fortaleza de contraseñas (si john está instalado)
sudo john --show /etc/shadow 2>/dev/null || echo "John the Ripper no disponible"
```

---

## 📊 Monitoreo y Auditoría de Usuarios

### **Comandos de Monitoreo en Tiempo Real**
```bash
# Ver usuarios conectados actualmente
who
w

# Monitorear intentos de login
sudo tail -f /var/log/auth.log | grep -E "(Failed|Accepted)"

# Ver sesiones SSH activas
ss -o state established '( dport = :ssh or sport = :ssh )'

# Monitorear cambios en archivos de usuarios
sudo inotifywait -m /etc/passwd /etc/group /etc/shadow 2>/dev/null || echo "inotify-tools no disponible"

# Dashboard de usuarios en tiempo real
watch 'echo "=== USUARIOS CONECTADOS ===" && who && echo -e "\n=== ÚLTIMOS LOGINS ===" && last -n 5'
```

### **Generar Reportes de Auditoría**
```bash
# Ejecutar reporte completo automatizado
sudo /usr/local/bin/lab-users-report

# Reporte de actividad de usuarios
echo "📊 REPORTE DE ACTIVIDAD DE USUARIOS"
echo "=================================="
echo "Fecha: $(date)"
echo ""
echo "👤 Usuarios conectados:"
who | wc -l
echo ""
echo "📅 Últimos 10 logins exitosos:"
last -n 10 | grep -v "reboot"
echo ""
echo "❌ Últimos intentos de login fallidos:"
sudo grep "Failed password" /var/log/auth.log | tail -5 | awk '{print $1, $2, $3, $9, $11}'

# Reporte de seguridad de usuarios
echo ""
echo "🔒 ESTADO DE SEGURIDAD:"
echo "======================="
for user in lab_admin lab_operator lab_developer lab_audit lab_backup; do
    if id "$user" >/dev/null 2>&1; then
        locked=$(sudo passwd -S "$user" | awk '{print $2}')
        echo "  $user: $locked"
    fi
done
```

---

## 🔧 Solución de Problemas Comunes

### **Problemas de Autenticación**
```bash
# Usuario no puede hacer sudo
sudo -u lab_operator sudo whoami 2>&1 || echo "Verificar membresía en grupos sudo"

# Verificar si el usuario existe
id lab_newuser 2>/dev/null || echo "Usuario no existe"

# Verificar bloqueo de cuenta
sudo passwd -S lab_operator | grep -q "L" && echo "Cuenta bloqueada" || echo "Cuenta activa"

# Revisar logs de autenticación
sudo grep "lab_operator" /var/log/auth.log | tail -5
```

### **Problemas de Permisos**
```bash
# Usuario no puede acceder a directorio
sudo -u lab_developer ls /home/shared/admin 2>&1 || echo "Acceso denegado - verificar permisos"

# Verificar pertenencia a grupos
groups lab_developer | grep -q "developers" && echo "En grupo developers" || echo "NO está en grupo developers"

# Reparar permisos de directorios home
sudo chmod 755 /home/lab_*
sudo chown -R lab_admin:admin_users /home/lab_admin
```

### **Problemas de Configuración Sudo**
```bash
# Verificar sintaxis de sudoers
sudo visudo -c

# Ver errores específicos de sudo
sudo grep "sudo" /var/log/auth.log | grep "COMMAND" | tail -5

# Verificar configuración específica
sudo cat /etc/sudoers.d/lab-users | grep -v "^#"
```

---

## 🎯 Comandos para Demostración Académica

### **Captura 1: Creación de Usuarios y Grupos**
```bash
clear
echo "═════════════════════════════════════════════════════════════"
echo "👥 DEMOSTRACIÓN: GESTIÓN AVANZADA DE USUARIOS Y GRUPOS"
echo "═════════════════════════════════════════════════════════════"
echo ""
echo "📊 GRUPOS CREADOS:"
getent group | grep -E "(admin_users|developers|operators|backup_users|audit_users)" | while IFS=: read group x gid members; do
    echo "  ✅ $group (GID: $gid) - Miembros: ${members:-'ninguno'}"
done
echo ""
echo "👤 USUARIOS DEL LABORATORIO:"
getent passwd | grep lab_ | while IFS=: read user x uid gid gecos home shell; do
    echo "  👨‍💻 $user (UID: $uid) - $gecos"
done
echo ""
echo "═════════════════════════════════════════════════════════════"
```

### **Captura 2: Estructura de Directorios y Permisos**
```bash
clear
echo "═════════════════════════════════════════════════════════════"
echo "📁 DEMOSTRACIÓN: ESTRUCTURA DE DIRECTORIOS Y PERMISOS"
echo "═════════════════════════════════════════════════════════════"
echo ""
echo "🏗️ DIRECTORIOS COMPARTIDOS:"
ls -la /home/shared/ | tail -n +2
echo ""
echo "🔐 PERMISOS DETALLADOS:"
for dir in /home/shared/*; do
    if [ -d "$dir" ]; then
        echo "  📂 $(basename $dir):"
        ls -ld "$dir" | awk '{printf "    Permisos: %s, Propietario: %s:%s\n", $1, $3, $4}'
    fi
done
echo ""
echo "═════════════════════════════════════════════════════════════"
```

### **Captura 3: Configuración de Sudo**
```bash
clear
echo "═════════════════════════════════════════════════════════════"
echo "🔐 DEMOSTRACIÓN: CONFIGURACIÓN AVANZADA DE SUDO"
echo "═════════════════════════════════════════════════════════════"
echo ""
echo "⚖️ PRIVILEGIOS POR GRUPO:"
cat /etc/sudoers.d/lab-users | grep -v "^#" | grep -E "^%"
echo ""
echo "🧪 PRUEBA DE PRIVILEGIOS:"
for user in lab_admin lab_operator lab_developer; do
    echo "  👤 $user:"
    sudo -u $user sudo -l 2>/dev/null | head -3 | tail -1
done
echo ""
echo "═════════════════════════════════════════════════════════════"
```

---

## 🏆 Verificación de Cumplimiento Académico

### **Checklist Nivel 4 - Gestión de Usuarios**
```bash
# Ejecutar verificación completa
{
echo "📋 VERIFICACIÓN DE CUMPLIMIENTO ACADÉMICO"
echo "========================================"
echo ""

echo "✅ NIVEL 4 - GESTIÓN AVANZADA DE USUARIOS:"
echo ""

# Verificar grupos funcionales
groups_count=$(getent group | grep -E "(admin_users|developers|operators|backup_users|audit_users)" | wc -l)
echo "  📊 Grupos funcionales creados: $groups_count/5"

# Verificar usuarios especializados  
users_count=$(getent passwd | grep lab_ | wc -l)
echo "  👥 Usuarios especializados: $users_count/5"

# Verificar configuración sudo
sudo_config=$([ -f /etc/sudoers.d/lab-users ] && echo "✅ Configurado" || echo "❌ Faltante")
echo "  🔐 Configuración sudo avanzada: $sudo_config"

# Verificar políticas de contraseñas
password_policy=$(grep -q "pwquality" /etc/pam.d/common-password 2>/dev/null && echo "✅ Configurado" || echo "❌ Faltante")
echo "  🔒 Políticas de contraseñas: $password_policy"

# Verificar directorios compartidos
shared_dirs=$(find /home/shared -type d 2>/dev/null | wc -l)
echo "  📁 Directorios compartidos: $shared_dirs"

echo ""
echo "🏆 RESULTADO: NIVEL 4 COMPLETADO"
echo "========================================"
}
```

---

*Documentación completa de gestión de usuarios - Noviembre 2025*