#!/bin/bash

# ================================================================================
# 🚀 IMPLEMENTACIÓN AUTOMÁTICA DEL LABORATORIO ANSIBLE
# Nivel 4 - Unidad 2 y 3 - Automatización Completa
# ================================================================================

set -e  # Salir si hay errores
LOG_FILE="implementacion_$(date +%Y%m%d_%H%M%S).log"

# Colores para salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# Función de logging
log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warning() {
    echo -e "${YELLOW}[ADVERTENCIA]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

# Banner de inicio
cat << 'EOF'
 ╔══════════════════════════════════════════════════════════════╗
 ║                🔧 LABORATORIO ANSIBLE                         ║
 ║           Implementación Automática Completa                 ║
 ║                                                              ║
 ║  📊 Nivel 4 - Unidad 2 (Procesos y Servicios)              ║
 ║  🔒 Nivel 4 - Unidad 3 (Seguridad del Sistema)             ║
 ║  👥 Sistema Avanzado de Gestión de Usuarios                 ║
 ╚══════════════════════════════════════════════════════════════╝
EOF

log "Iniciando implementación automática..."

# ================================================================================
# PASO 1: VERIFICACIONES PREVIAS
# ================================================================================

log "🔍 Realizando verificaciones previas..."

# Verificar si es Ubuntu/Debian
if ! command -v apt &> /dev/null; then
    error "Este script está diseñado para sistemas basados en Ubuntu/Debian"
fi

# Verificar conexión a internet
if ! ping -c 1 google.com &> /dev/null; then
    error "Sin conexión a Internet. Verificar conectividad."
fi

# Verificar espacio en disco (mínimo 2GB)
AVAILABLE_SPACE=$(df / | tail -1 | awk '{print $4}')
if [ "$AVAILABLE_SPACE" -lt 2000000 ]; then
    error "Espacio insuficiente. Se requieren al menos 2GB libres."
fi

log "✅ Verificaciones previas completadas"

# ================================================================================
# PASO 2: INSTALACIÓN DE DEPENDENCIAS
# ================================================================================

log "📦 Instalando dependencias del sistema..."

sudo apt update || error "Error al actualizar repositorios"

# Instalar paquetes esenciales
PACKAGES="ansible python3 python3-pip git curl wget openssh-server openssh-client"
sudo apt install -y $PACKAGES || error "Error al instalar dependencias básicas"

# Verificar instalaciones
for pkg in ansible python3 git; do
    if ! command -v "$pkg" &> /dev/null; then
        error "$pkg no se instaló correctamente"
    fi
done

log "✅ Dependencias instaladas correctamente"

# ================================================================================
# PASO 3: CONFIGURACIÓN SSH LOCAL
# ================================================================================

log "🔐 Configurando acceso SSH local..."

# Crear claves SSH si no existen
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" || error "Error al generar claves SSH"
    log "Claves SSH generadas"
fi

# Configurar acceso sin contraseña
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys 2>/dev/null || true
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh

# Probar conexión SSH
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no localhost 'echo "SSH OK"' &> /dev/null; then
    log "✅ SSH configurado correctamente"
else
    warning "SSH requiere configuración manual"
fi

# ================================================================================
# PASO 4: CLONAR O ACTUALIZAR REPOSITORIO
# ================================================================================

log "📥 Obteniendo código del proyecto..."

REPO_DIR="$HOME/ansible"

if [ -d "$REPO_DIR" ]; then
    log "Actualizando repositorio existente..."
    cd "$REPO_DIR"
    git pull origin main || warning "Error al actualizar repositorio"
else
    log "Clonando repositorio desde GitHub..."
    git clone https://github.com/JhonatanCh29/ansible.git "$REPO_DIR" || error "Error al clonar repositorio"
fi

cd "$REPO_DIR" || error "No se puede acceder al directorio del proyecto"

# ================================================================================
# PASO 5: CONFIGURACIÓN DEL INVENTARIO LOCAL
# ================================================================================

log "⚙️  Configurando inventario local..."

mkdir -p inventory

cat > inventory/local_hosts.yml << 'EOF'
local_lab:
  hosts:
    localhost:
      ansible_connection: local
      ansible_host: 127.0.0.1

all:
  vars:
    ansible_become: true
    ansible_python_interpreter: /usr/bin/python3
EOF

log "✅ Inventario local configurado"

# ================================================================================
# PASO 6: CONFIGURACIÓN DE VARIABLES
# ================================================================================

log "📝 Configurando variables del proyecto..."

# Configurar archivo vault (sin encriptar para simplificar)
mkdir -p group_vars/all

cat > group_vars/all/vault.yml << 'EOF'
# Configuración de laboratorio - Nivel académico
# IMPORTANTE: En producción, usar ansible-vault encrypt

# Configuración de red
network_interface: "$(ip route | awk '/default/ { print $5 }')"
lab_network: "192.168.50.0/24"

# Configuración de usuarios del laboratorio
lab_users:
  - name: lab_admin
    groups: [admin_users, sudo]
    uid: 3000
  - name: lab_operator
    groups: [operators]
    uid: 3001
  - name: lab_developer
    groups: [developers]
    uid: 3002
  - name: lab_audit
    groups: [audit_users]
    uid: 3003
  - name: lab_backup
    groups: [backup_users]
    uid: 3004

# Configuración de grupos del laboratorio  
lab_groups:
  - name: admin_users
    gid: 2000
  - name: developers
    gid: 2001
  - name: operators
    gid: 2002
  - name: backup_users
    gid: 2003
  - name: audit_users
    gid: 2004

# Configuración de seguridad
security_policies:
  password_max_days: 90
  password_min_days: 7
  password_warn_age: 14
  umask_default: "0022"
  
# Configuración de servicios
services_config:
  enable_firewall: true
  enable_fail2ban: true
  enable_clamav: true
  enable_auditd: true
EOF

log "✅ Variables configuradas"

# ================================================================================
# PASO 7: VERIFICACIÓN DE PLAYBOOKS
# ================================================================================

log "✅ Verificando sintaxis de playbooks..."

# Verificar sintaxis del playbook principal
if ansible-playbook --syntax-check security_playbook.yml &> /dev/null; then
    log "✅ Sintaxis de playbooks correcta"
else
    error "Error de sintaxis en playbooks. Revisar configuración."
fi

# ================================================================================
# PASO 8: EJECUTAR IMPLEMENTACIÓN
# ================================================================================

log "🚀 Ejecutando implementación del laboratorio..."

info "Esto puede tomar varios minutos. Progreso guardado en $LOG_FILE"

# Ejecutar playbook con configuración local
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
    -i inventory/local_hosts.yml \
    security_playbook.yml \
    --ask-become-pass \
    -v 2>&1 | tee -a "$LOG_FILE"

PLAYBOOK_EXIT_CODE=${PIPESTATUS[0]}

if [ $PLAYBOOK_EXIT_CODE -eq 0 ]; then
    log "✅ Implementación completada exitosamente"
else
    error "Error durante la implementación. Revisar logs para detalles."
fi

# ================================================================================
# PASO 9: VERIFICACIONES POST-IMPLEMENTACIÓN
# ================================================================================

log "🔍 Realizando verificaciones post-implementación..."

# Array de servicios a verificar
SERVICES_TO_CHECK=("ssh" "ufw" "fail2ban" "clamav-daemon" "auditd")

info "Verificando servicios críticos:"
for service in "${SERVICES_TO_CHECK[@]}"; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        log "  ✅ $service: ACTIVO"
    else
        warning "  ⚠️  $service: INACTIVO o NO INSTALADO"
    fi
done

# Verificar usuarios creados
info "Verificando usuarios del laboratorio:"
for user in lab_admin lab_operator lab_developer lab_audit lab_backup; do
    if id "$user" &>/dev/null; then
        log "  ✅ Usuario $user: CREADO"
    else
        warning "  ⚠️  Usuario $user: NO ENCONTRADO"
    fi
done

# Verificar grupos
info "Verificando grupos del laboratorio:"
for group in admin_users developers operators backup_users audit_users; do
    if getent group "$group" &>/dev/null; then
        log "  ✅ Grupo $group: CREADO"
    else
        warning "  ⚠️  Grupo $group: NO ENCONTRADO"
    fi
done

# ================================================================================
# PASO 10: GENERACIÓN DE REPORTE
# ================================================================================

log "📊 Generando reporte de implementación..."

REPORT_FILE="reporte_implementacion_$(date +%Y%m%d_%H%M%S).txt"

cat > "$REPORT_FILE" << EOF
================================================================================
REPORTE DE IMPLEMENTACIÓN - LABORATORIO ANSIBLE
================================================================================
Fecha: $(date)
Sistema: $(lsb_release -d | cut -f2)
Usuario: $(whoami)
Directorio: $(pwd)

RESUMEN EJECUTIVO:
- ✅ Implementación automática completada
- 📊 Nivel 4 - Unidad 2: Procesos y Servicios
- 🔒 Nivel 4 - Unidad 3: Seguridad del Sistema
- 👥 Sistema avanzado de gestión de usuarios

COMPONENTES INSTALADOS:

🔐 SEGURIDAD:
$(systemctl is-active fail2ban &>/dev/null && echo "  ✅ Fail2Ban (IDS/IPS)" || echo "  ❌ Fail2Ban")
$(systemctl is-active clamav-daemon &>/dev/null && echo "  ✅ ClamAV (Antivirus)" || echo "  ❌ ClamAV")
$(systemctl is-active auditd &>/dev/null && echo "  ✅ AUDITD (Auditoría)" || echo "  ❌ AUDITD")
$(systemctl is-active ufw &>/dev/null && echo "  ✅ UFW (Firewall)" || echo "  ❌ UFW")

👥 USUARIOS Y GRUPOS:
$(id lab_admin &>/dev/null && echo "  ✅ lab_admin (Administrador)" || echo "  ❌ lab_admin")
$(id lab_operator &>/dev/null && echo "  ✅ lab_operator (Operador)" || echo "  ❌ lab_operator")
$(id lab_developer &>/dev/null && echo "  ✅ lab_developer (Desarrollador)" || echo "  ❌ lab_developer")
$(id lab_audit &>/dev/null && echo "  ✅ lab_audit (Auditoría)" || echo "  ❌ lab_audit")
$(id lab_backup &>/dev/null && echo "  ✅ lab_backup (Respaldos)" || echo "  ❌ lab_backup")

ARCHIVOS GENERADOS:
- $LOG_FILE (Log detallado)
- $REPORT_FILE (Este reporte)

PRÓXIMOS PASOS:
1. Revisar logs para verificar instalación completa
2. Probar funcionalidad con: ansible-playbook playbooks/manage_users.yml
3. Generar documentación académica con capturas de pantalla
4. Verificar cumplimiento de rúbricas académicas

Para más información, consultar:
- DOCUMENTACION_COMPLETA.md
- GUIA_COMANDOS_RAPIDA.md
- SOLUCION_PROBLEMAS_RAPIDA.md
================================================================================
EOF

log "📄 Reporte generado: $REPORT_FILE"

# ================================================================================
# FINALIZACIÓN
# ================================================================================

cat << 'EOF'

 ╔══════════════════════════════════════════════════════════════╗
 ║                  🎉 IMPLEMENTACIÓN COMPLETADA                ║
 ║                                                              ║
 ║  ✅ Laboratorio Ansible implementado exitosamente           ║
 ║  📚 Documentación académica disponible                      ║
 ║  🔒 Seguridad del sistema configurada                       ║
 ║  👥 Gestión de usuarios implementada                        ║
 ║                                                              ║
 ║  📍 Próximo paso: Revisar documentación                     ║
 ╚══════════════════════════════════════════════════════════════╝

EOF

log "🎯 Implementación completada exitosamente"
log "📊 Logs disponibles en: $LOG_FILE"
log "📄 Reporte disponible en: $REPORT_FILE"

info "Para verificar la implementación, ejecutar:"
echo "  cd ~/ansible && ansible-playbook playbooks/manage_users.yml"
echo ""
info "Para solución de problemas, consultar:"
echo "  cat ~/ansible/SOLUCION_PROBLEMAS_RAPIDA.md"
echo ""

log "✨ ¡Laboratorio listo para evaluación académica!"