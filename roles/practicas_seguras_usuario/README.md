# Rol: Prácticas Seguras de Usuario

## Descripción
Este rol implementa políticas avanzadas de seguridad para usuarios del sistema, incluyendo restricciones de acceso, políticas de sesión, y configuraciones de seguridad que cumplen con los requisitos de **Nivel 4** para gestión de usuarios y permisos.

## Características Implementadas

### 🔐 Políticas de Sesión
- Timeout automático de sesiones (15 minutos por defecto)
- Configuración de timeout SSH con reconexión automática
- Control de sesiones concurrentes

### 🚫 Restricciones de Acceso
- Bloqueo de cuenta tras intentos fallidos de login
- Restricción de acceso SSH por grupos de usuarios
- Control granular de permisos sudo

### 📋 Auditoría y Logging
- Logging detallado de comandos sudo
- Registro de intentos de login y accesos
- Separación de logs de seguridad

### 🛡️ Hardening del Sistema
- Configuración segura de umask
- Políticas avanzadas de contraseñas
- Deshabilitación de servicios innecesarios

## Variables Configurables

```yaml
# Timeouts
session_timeout: 900  # Timeout de sesión en segundos

# Políticas de login
max_login_attempts: 3  # Intentos máximos antes de bloqueo
account_lockout_time: 1800  # Tiempo de bloqueo en segundos

# Configuración SSH
restrict_ssh_access: true
allowed_ssh_groups: "users"

# Sudo
sudo_require_tty: true
sudo_log_file: "/var/log/sudo.log"
```

## Uso

```yaml
- name: Aplicar prácticas seguras de usuario
  hosts: all
  roles:
    - role: practicas_seguras_usuario
      vars:
        session_timeout: 600
        max_login_attempts: 5
```

## Requisitos

- Sistema operativo: Ubuntu/Debian
- Privilegios: sudo/root
- Servicios: SSH, rsyslog

## Cumplimiento Académico

Este rol cumple con los criterios de **Nivel 4** para:
- Gestión avanzada de usuarios y permisos
- Implementación de políticas de seguridad
- Auditoría y monitoreo de accesos
- Restricciones granulares de sistema

## Archivos Principales

- `tasks/main.yml`: Tareas de configuración
- `handlers/main.yml`: Manejadores de servicios
- `defaults/main.yml`: Variables por defecto
- `README.md`: Esta documentación