# Proyecto Ansible

Este repositorio contiene playbooks y roles para levantar un laboratorio de red
con una VM que actúa como router/DHCP (`vm_jhonatan`) y clientes (`mint_jhonatan`).

## 🚀 Guía de inicio rápido

### Pasos para preparar el nodo de control

1. **Ejecutar el script de bootstrap** para instalar dependencias en la VM de control:
   ```bash
   ./bootstrap_control.sh
   ```

2. **Configurar claves SSH** y copiar la pública a las VMs objetivo:
   ```bash
   # desde la VM de control
   cat ~/.ssh/id_ed25519.pub
   # añadir esa clave en /home/jhonatan/.ssh/authorized_keys en cada VM
   ```

3. **Configurar Ansible Vault** (recomendado para contraseñas):
   ```bash
   # Crear archivo cifrado con contraseñas
   ansible-vault create group_vars/all/vault.yml
   
   # Dentro del archivo, definir variables como:
   # vault_password_adminlab: "contraseña_segura"
   # vault_password_tecnico1: "otra_contraseña"
   # vault_password_profesor1: "otra_contraseña_más"
   ```

### 📋 Ejecución de playbooks

4. **Comprobaciones previas** (máquina control):
   ```bash
   # Activar venv si lo creaste con bootstrap_control.sh
   source ~/.ansible-venv/bin/activate
   
   # Verificar sintaxis
   ansible-lint .
   ansible-playbook playbooks/setup_network_server.yml --syntax-check
   
   # Verificar conectividad
   ansible all -m ping
   ```

5. **Ejecutar configuración principal**:
   ```bash
   # Configurar el servidor de red (vm_jhonatan)
   ansible-playbook playbooks/setup_network_server.yml --ask-vault-pass
   
   # Verificar que todo funciona correctamente
   ansible-playbook playbooks/verificacion_laboratorio.yml --ask-vault-pass
   ```

## 🎯 Características del proyecto (Nivel 4)

### Gestión de procesos y servicios
- ✅ Control avanzado con herramientas systemd
- ✅ Monitoreo automático de servicios críticos
- ✅ Reinicio automático de servicios fallidos
- ✅ Optimización y alertas configurables

### Gestión de seguridad por usuario
- ✅ Políticas de contraseña definidas y validadas
- ✅ Roles y permisos con restricciones claras
- ✅ Auditoría automática de usuarios y actividades
- ✅ Uso de Ansible Vault para secretos

### Automatización de tareas
- ✅ Automatización robusta y validada
- ✅ Scripts idempotentes con manejo de errores
- ✅ Validación automática de configuraciones
- ✅ Reportes y alertas automatizadas

### Administración de almacenamiento
- ✅ Gestión avanzada con LVM y políticas claras
- ✅ Monitoreo de espacio y alertas automáticas
- ✅ Rotación de logs y backup automatizado
- ✅ Políticas de limpieza y retención

## 🔧 Estructura del proyecto

```
├── playbooks/
│   ├── setup_network_server.yml      # Configuración principal del laboratorio
│   ├── verificacion_laboratorio.yml  # Validación completa del sistema
│   └── configure_vm_networks.yml     # Configuración de red específica
├── roles/
│   ├── red_lab/                      # Gestión de red y DHCP
│   ├── procesos_servicios/           # Gestión de procesos y servicios
│   ├── usuarios_permisos/            # Administración de usuarios y seguridad
│   ├── tareas_automatizadas/         # Automatización y cron jobs
│   └── almacenamiento_sistemas/      # Gestión de almacenamiento y backups
├── inventory/
│   ├── hosts.yml                     # Inventario de hosts
│   └── group_vars/
│       ├── lab_academico.yml         # Variables del grupo
│       └── all/
│           └── vault_example.yml     # Ejemplo para crear vault cifrado
└── ansible.cfg                       # Configuración de Ansible
```

## 📊 Monitoreo y validación

El proyecto incluye scripts automáticos de monitoreo que se ejecutan periódicamente:

- **Monitoreo de servicios**: Cada 5 minutos
- **Verificación de disco**: Cada 15 minutos
- **Auditoría de usuarios**: Diario a las 7:00
- **Validación del sistema**: Diario a las 6:30
- **Backup automático**: Configurable (por defecto 1:30 AM)

Los reportes se guardan en `/var/log/` en cada host y pueden ser revisados manualmente o enviados por email si se configura.

## 🔐 Notas de seguridad

- Este repositorio usa `become` en lugar de conectarse como root directamente
- Las contraseñas deben almacenarse en `group_vars/all/vault.yml` cifrado
- Los usuarios tienen permisos limitados según su rol (docentes, soporte, laboratorio)
- Se incluye auditoría automática de actividades y cambios en el sistema

## 🆘 Solución de problemas

1. **Error de conexión SSH**: Verificar que las claves públicas estén en `authorized_keys` de los hosts objetivo
2. **Ansible pide contraseña**: Usar `--ask-vault-pass` si tienes vault cifrado
3. **Servicios fallan**: Ejecutar el playbook de verificación para diagnóstico detallado
4. **Problemas de permisos**: Verificar que `ansible_become: true` esté configurado en el grupo

Para más ayuda, revisar los logs en `/var/log/` de cada host o ejecutar:
```bash
ansible-playbook playbooks/verificacion_laboratorio.yml --ask-vault-pass
```