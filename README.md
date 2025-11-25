# 🏫 LABORATORIO ANSIBLE - NIVEL ACADÉMICO 4
## Gestión Avanzada de Sistemas y Seguridad

[![License](https://img.shields.io/badge/License-Academic-blue.svg)](LICENSE)
[![Ansible](https://img.shields.io/badge/Ansible-2.9%2B-red.svg)](https://www.ansible.com/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%2B-orange.svg)](https://ubuntu.com/)

---

## 📋 **DESCRIPCIÓN DEL PROYECTO**

Este repositorio contiene una implementación completa de un laboratorio de automatización con **Ansible** diseñado para cumplir con los estándares académicos de **Nivel 4** en:

- 📊 **Unidad 2**: Gestión de Procesos y Servicios
- 🔒 **Unidad 3**: Seguridad del Sistema Operativo
- 👥 **Sistema Avanzado**: Gestión de Usuarios y Permisos

### 🎯 **Objetivos Académicos**
- Demostrar competencias avanzadas en automatización de sistemas
- Implementar medidas de seguridad empresarial
- Gestionar usuarios y permisos de forma granular
- Aplicar buenas prácticas de DevOps y administración de sistemas

---

## 🚀 **IMPLEMENTACIÓN RÁPIDA**

### **Opción 1: Implementación Automática (Recomendada)**
```bash
# 1. Clonar el repositorio
git clone https://github.com/JhonatanCh29/ansible.git
cd ansible

# 2. Ejecutar implementación automática
./implementar_laboratorio.sh
```

### **Opción 2: Implementación Manual**
```bash
# 1. Instalar dependencias
sudo apt update && sudo apt install -y ansible python3 git

# 2. Configurar SSH local
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# 3. Ejecutar playbook
ansible-playbook -i inventory/local_hosts.yml security_playbook.yml --ask-become-pass
   ansible-playbook playbooks/setup_network_server.yml --ask-vault-pass
   
```

---

## 📁 **ESTRUCTURA DEL PROYECTO**

```
📦 ansible/
├── 🎭 playbooks/
│   ├── security_playbook.yml      # 🔒 Playbook principal de seguridad
│   └── manage_users.yml           # 👥 Gestión de usuarios
├── 🎪 roles/
│   ├── seguridad_local/           # 🛡️  Antivirus y escaneo
│   ├── proteccion_amenazas/       # 🔍 IDS/IPS y monitoreo
│   ├── practicas_seguras_usuario/ # 🔐 Políticas de usuario
│   └── usuarios_permisos/         # 👤 Gestión completa de usuarios
├── 📊 inventory/
│   ├── hosts.yml                  # 🌐 Inventario de red
│   └── local_hosts.yml            # 💻 Configuración local
├── ⚙️  group_vars/
│   └── all/vault.yml              # 🔑 Variables de configuración
├── 📚 Documentación/
│   ├── DOCUMENTACION_COMPLETA.md  # 📖 Guía completa
│   ├── GUIA_COMANDOS_RAPIDA.md    # ⚡ Comandos rápidos
│   ├── GUIA_CAPTURAS_ACADEMICAS.md# 📸 Guía de capturas
│   ├── GUIA_IMPLEMENTACION_DESDE_CERO.md # 🆕 Implementación desde cero
│   └── SOLUCION_PROBLEMAS_RAPIDA.md # 🔧 Troubleshooting
└── 🛠️  implementar_laboratorio.sh  # 🚀 Script de implementación automática
```

---

## 🔧 **COMPONENTES PRINCIPALES**

### 🛡️ **SEGURIDAD DEL SISTEMA**
| Componente | Función | Estado |
|------------|---------|--------|
| **ClamAV** | Antivirus con escaneo automático | ✅ Implementado |
| **Fail2Ban** | Sistema IDS/IPS contra intrusiones | ✅ Implementado |
| **AUDITD** | Auditoría del sistema en tiempo real | ✅ Implementado |
| **AIDE** | Verificación de integridad de archivos | ✅ Implementado |
| **UFW** | Firewall con reglas personalizadas | ✅ Implementado |

### 👥 **GESTIÓN DE USUARIOS**
| Usuario | Grupo Principal | UID | Función |
|---------|----------------|-----|---------|
| **lab_admin** | admin_users | 3000 | Administrador del sistema |
| **lab_operator** | operators | 3001 | Operaciones diarias |
| **lab_developer** | developers | 3002 | Desarrollo y testing |
| **lab_audit** | audit_users | 3003 | Auditoría y compliance |
| **lab_backup** | backup_users | 3004 | Gestión de respaldos |

### 📁 **ESTRUCTURA DE DIRECTORIOS**
```
/opt/lab_data/
├── shared/         # Espacio compartido (todos los usuarios)
├── admin/          # Solo administradores
├── development/    # Solo desarrolladores
├── operations/     # Solo operadores
├── backups/        # Solo equipo de backup
└── audit/          # Solo equipo de auditoría
```

---

## ✅ **CUMPLIMIENTO ACADÉMICO**

### 📊 **Nivel 4 - Unidad 2: Procesos y Servicios**
- [x] Gestión automatizada de servicios del sistema
- [x] Configuración de servicios críticos (SSH, Firewall, etc.)
- [x] Monitoreo y mantenimiento automatizado
- [x] Implementación de servicios de seguridad

### 🔒 **Nivel 4 - Unidad 3: Seguridad del Sistema**
- [x] Configuración avanzada de firewall (UFW)
- [x] Sistema de detección de intrusiones (Fail2Ban)
- [x] Antivirus con escaneo automatizado (ClamAV)
- [x] Auditoría del sistema (AUDITD)
- [x] Verificación de integridad (AIDE)
- [x] Políticas de seguridad para usuarios
- [x] Gestión granular de permisos

---

## 🎓 **DOCUMENTACIÓN ACADÉMICA**

| Documento | Propósito | Nivel |
|-----------|-----------|--------|
| [📖 Documentación Completa](DOCUMENTACION_COMPLETA.md) | Guía técnica detallada | Avanzado |
| [⚡ Comandos Rápidos](GUIA_COMANDOS_RAPIDA.md) | Referencia rápida | Básico |
| [📸 Capturas Académicas](GUIA_CAPTURAS_ACADEMICAS.md) | Evidencias para evaluación | Académico |
| [🆕 Implementación desde Cero](GUIA_IMPLEMENTACION_DESDE_CERO.md) | Despliegue en VM limpia | Intermedio |
| [🔧 Solución de Problemas](SOLUCION_PROBLEMAS_RAPIDA.md) | Troubleshooting | Avanzado |

---

## 🔍 **VERIFICACIÓN Y TESTING**

### **Verificación Rápida del Sistema**
```bash
# Ejecutar verificación completa
ansible-playbook playbooks/manage_users.yml

# Verificar servicios de seguridad
systemctl status clamav-daemon fail2ban auditd ufw

# Verificar usuarios creados
for user in lab_admin lab_operator lab_developer lab_audit lab_backup; do
    echo "Usuario $user: $(id $user 2>/dev/null && echo 'OK' || echo 'NO ENCONTRADO')"
done
```

### **Testing de Seguridad**
```bash
# Verificar configuración de firewall
sudo ufw status verbose

# Verificar logs de Fail2Ban
sudo fail2ban-client status

# Verificar estado del antivirus
sudo systemctl status clamav-daemon

# Verificar auditoría del sistema
sudo aureport --summary
```

---

## 🆘 **SOLUCIÓN DE PROBLEMAS**

### **Problemas Comunes y Soluciones Rápidas**

| Problema | Solución Rápida |
|----------|-----------------|
| "No module named ansible" | `sudo apt install ansible` |
| "Permission denied (publickey)" | Ver [guía SSH](SOLUCION_PROBLEMAS_RAPIDA.md#ssh) |
| "sudo: a password is required" | Usar `--ask-become-pass` |
| Servicios no se inician | Verificar logs: `journalctl -xe` |

> 📚 **Para problemas específicos**: Consultar [SOLUCION_PROBLEMAS_RAPIDA.md](SOLUCION_PROBLEMAS_RAPIDA.md)

---

## 📈 **MÉTRICAS DE ÉXITO**

### **Criterios de Evaluación Académica**
- ✅ **Automatización**: Despliegue completo sin intervención manual
- ✅ **Seguridad**: Todas las herramientas funcionando correctamente  
- ✅ **Usuarios**: Sistema de gestión granular implementado
- ✅ **Documentación**: Guías completas y casos de uso
- ✅ **Troubleshooting**: Soluciones para problemas comunes
- ✅ **Escalabilidad**: Fácil extensión y modificación

### **Indicadores Técnicos**
```bash
# Comando de verificación completa
curl -s https://raw.githubusercontent.com/JhonatanCh29/ansible/main/verificar_sistema.sh | bash
```

---

## 🤝 **CONTRIBUCIONES Y SOPORTE**

### **Información del Proyecto**
- **Autor**: Jhonatan
- **Curso**: Administración de Sistemas Operativos
- **Nivel**: Académico 4
- **Versión**: 2.0.0

### **Repositorio**
- **GitHub**: [JhonatanCh29/ansible](https://github.com/JhonatanCh29/ansible)
- **Documentación**: Incluida en el repositorio
- **Licencia**: Uso académico

---

## 🎯 **PRÓXIMOS PASOS**

1. **Implementar**: Ejecutar `./implementar_laboratorio.sh`
2. **Verificar**: Comprobar todos los servicios y usuarios
3. **Documentar**: Tomar capturas para evidencia académica
4. **Evaluar**: Verificar cumplimiento de rúbricas
5. **Extender**: Agregar funcionalidades adicionales según necesidad

---

<div align="center">

### 🎓 **¡LABORATORIO LISTO PARA EVALUACIÓN ACADÉMICA!**

**Nivel 4 | Unidad 2 y 3 | Gestión Avanzada de Sistemas**

*Automatización • Seguridad • Gestión de Usuarios • Documentación Completa*

</div>