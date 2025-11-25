# Rol: Gestión de Usuarios y Permisos

## Descripción
Este rol implementa un sistema completo de **gestión de usuarios, grupos y permisos** para el laboratorio académico. Cumple con los requisitos de **Nivel 4** para administración avanzada de usuarios.

## Características Implementadas

### 👥 **Gestión de Grupos**
- **admin_users** (GID: 2000): Administradores con privilegios completos
- **developers** (GID: 2001): Desarrolladores con acceso a herramientas
- **operators** (GID: 2002): Operadores de sistemas y servicios
- **backup_users** (GID: 2003): Usuarios para tareas de respaldo
- **audit_users** (GID: 2004): Usuarios de auditoría (solo lectura)

### 👤 **Usuarios del Laboratorio**
- **lab_admin** (UID: 3000): Administrador principal del laboratorio
- **lab_operator** (UID: 3001): Operador de sistemas
- **lab_developer** (UID: 3002): Desarrollador de aplicaciones
- **lab_audit** (UID: 3003): Usuario de auditoría y monitoreo
- **lab_backup** (UID: 3004): Usuario para tareas de backup

### 📁 **Directorios Compartidos**
- `/home/shared/admin` - Área administrativa (rwx admin_users)
- `/home/shared/development` - Área de desarrollo (rwx developers, rx operators)
- `/home/shared/operations` - Área operativa (rwx operators, admin_users)
- `/home/shared/backups` - Área de respaldos (rwx backup_users)
- `/home/shared/audit` - Área de auditoría (r-x audit_users)

### 🔐 **Configuración de Sudo**
```bash
# Administradores: Acceso completo
%admin_users ALL=(ALL:ALL) ALL

# Operadores: Gestión de servicios
%operators ALL=(ALL) NOPASSWD: /bin/systemctl restart *

# Desarrolladores: Instalación de paquetes y logs
%developers ALL=(ALL) NOPASSWD: /usr/bin/apt, /bin/cat /var/log/*

# Backup: Herramientas de respaldo
%backup_users ALL=(ALL) NOPASSWD: /bin/tar, /bin/rsync

# Auditoría: Solo lectura de configuraciones
%audit_users ALL=(ALL) NOPASSWD: /bin/cat /etc/*, /bin/ls
```

### 🔒 **Políticas de Seguridad**
- **Contraseñas**: Mínimo 12 caracteres, mayúsculas, minúsculas, números y símbolos
- **Expiración**: 90 días máximo, 14 días de advertencia
- **Límites de recursos**: Configurados por grupo de usuario
- **SSH**: Acceso restringido por grupos

## Variables Configurables

Ver `defaults/main.yml` para configuración completa de usuarios, grupos y políticas.

## Uso

```yaml
- name: Implementar gestión de usuarios
  hosts: all
  roles:
    - role: usuarios_permisos
      vars:
        password_policy:
          min_length: 14
          max_age_days: 60
```

## Comandos de Verificación

### **Ver Usuarios Creados**
```bash
# Listar usuarios del laboratorio
getent passwd | grep lab_

# Ver grupos de un usuario
groups lab_admin

# Ver información completa
id lab_developer
```

### **Verificar Grupos**
```bash
# Listar grupos del laboratorio
getent group | grep -E "(admin_users|developers|operators|backup_users|audit_users)"

# Ver miembros de un grupo
getent group admin_users
```

### **Verificar Permisos de Directorios**
```bash
# Ver permisos de directorios compartidos
ls -la /home/shared/

# Verificar ACLs (si están configuradas)
getfacl /home/shared/development
```

### **Verificar Configuración Sudo**
```bash
# Ver configuración sudo del laboratorio
sudo cat /etc/sudoers.d/lab-users

# Probar acceso sudo de un usuario
sudo -u lab_operator sudo -l
```

### **Script de Reporte Automático**
```bash
# Ejecutar reporte completo de usuarios
sudo /usr/local/bin/lab-users-report
```

## Cumplimiento Académico

Este rol cumple con los criterios de **Nivel 4** para:

✅ **Gestión Avanzada de Usuarios**
- Creación automatizada de usuarios con UIDs específicos
- Asignación de grupos primarios y secundarios
- Configuración de shells y directorios home

✅ **Gestión de Grupos y Permisos**  
- Grupos funcionales con GIDs organizados
- Permisos granulares por función de usuario
- Configuración de sudo diferenciada por rol

✅ **Políticas de Seguridad**
- Políticas robustas de contraseñas
- Límites de recursos por usuario
- Expiración y rotación de credenciales

✅ **Automatización Completa**
- Implementación idempotente con Ansible
- Configuración declarativa y reproducible
- Reportes automáticos de estado

## Archivos del Rol

- `tasks/main.yml`: Tareas de creación y configuración
- `defaults/main.yml`: Variables por defecto
- `README.md`: Esta documentación

## Tags Disponibles

- `groups`: Solo crear grupos
- `users`: Solo crear usuarios  
- `directories`: Solo crear directorios
- `sudo`: Solo configurar sudo
- `password_policy`: Solo políticas de contraseñas
- `ssh_config`: Solo configuración SSH
- `limits`: Solo límites de recursos
- `reporting`: Solo herramientas de reporte