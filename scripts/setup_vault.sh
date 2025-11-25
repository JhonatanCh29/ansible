#!/bin/bash

# 🔐 Script de Configuración Segura de Ansible Vault
# Este script te ayuda a configurar las claves privadas de forma segura

set -e  # Salir si hay errores

ANSIBLE_DIR="/home/jhonatan/ansible"
VAULT_FILE="$ANSIBLE_DIR/group_vars/all/vault.yml"
SSH_DIR="$HOME/.ssh"

echo "🔐 CONFIGURACIÓN SEGURA DE ANSIBLE VAULT"
echo "======================================="

# Función para generar contraseña segura
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# 1. Verificar si ya existe una clave SSH
check_ssh_key() {
    echo "🔍 Verificando claves SSH existentes..."
    
    if [[ -f "$SSH_DIR/id_rsa" ]]; then
        echo "✅ Clave SSH encontrada en $SSH_DIR/id_rsa"
        read -p "¿Quieres usar la clave existente? (s/n): " use_existing
        if [[ $use_existing == "s" || $use_existing == "S" ]]; then
            SSH_PRIVATE_KEY=$(cat "$SSH_DIR/id_rsa")
            SSH_PUBLIC_KEY=$(cat "$SSH_DIR/id_rsa.pub")
            return 0
        fi
    fi
    
    echo "🔑 Generando nueva clave SSH..."
    ssh-keygen -t rsa -b 4096 -C "ansible@$(hostname)" -f "$SSH_DIR/id_rsa_ansible" -N ""
    SSH_PRIVATE_KEY=$(cat "$SSH_DIR/id_rsa_ansible")
    SSH_PUBLIC_KEY=$(cat "$SSH_DIR/id_rsa_ansible.pub")
}

# 2. Crear archivo temporal con variables reales
create_vault_content() {
    echo "📝 Creando contenido del vault..."
    
    # Generar contraseñas seguras
    ADMIN_PASS=$(generate_password)
    MYSQL_PASS=$(generate_password)
    POSTGRES_PASS=$(generate_password)
    JWT_SECRET=$(generate_password)
    ENCRYPT_KEY=$(openssl rand -hex 16)
    
    cat > "/tmp/vault_temp.yml" << EOF
---
# 🔐 Variables Encriptadas - Configuración Real
# Generado automáticamente el $(date)

# 🔑 Credenciales del Sistema
vault_admin_password: "$ADMIN_PASS"
vault_mysql_root_password: "$MYSQL_PASS"
vault_postgresql_password: "$POSTGRES_PASS"

# 🌐 Claves API y Servicios
vault_api_key: "$(generate_password)"
vault_github_token: "ghp_$(generate_password)"
vault_smtp_password: "$(generate_password)"

# 🔐 Clave SSH Privada
vault_ssh_private_key: |
$(echo "$SSH_PRIVATE_KEY" | sed 's/^/  /')

# 🔐 Clave SSH Pública
vault_ssh_public_key: "$SSH_PUBLIC_KEY"

# 🛡️ Tokens de Seguridad
vault_jwt_secret: "$JWT_SECRET"
vault_encryption_key: "$ENCRYPT_KEY"

# 🌍 Variables de Entorno
vault_database_url: "postgresql://app_user:$POSTGRES_PASS@localhost:5432/app_db"
vault_redis_url: "redis://localhost:6379"

# 🔑 Otros secretos
vault_ldap_bind_password: "$(generate_password)"
vault_backup_encryption_key: "$(generate_password)"
EOF
}

# 3. Encriptar el archivo vault
encrypt_vault() {
    echo "🔒 Encriptando archivo vault..."
    echo "📋 IMPORTANTE: Guarda la contraseña del vault en un lugar seguro!"
    echo ""
    
    # Copiar contenido temporal al archivo real
    cp "/tmp/vault_temp.yml" "$VAULT_FILE"
    
    # Encriptar
    ansible-vault encrypt "$VAULT_FILE"
    
    # Limpiar archivo temporal
    rm -f "/tmp/vault_temp.yml"
    
    echo "✅ Archivo vault encriptado exitosamente"
}

# 4. Mostrar resumen de configuración
show_summary() {
    echo ""
    echo "🎉 CONFIGURACIÓN COMPLETADA"
    echo "=========================="
    echo ""
    echo "📁 Archivos creados/modificados:"
    echo "   • $VAULT_FILE (encriptado)"
    echo "   • $SSH_DIR/id_rsa_ansible (nueva clave SSH)"
    echo "   • $SSH_DIR/id_rsa_ansible.pub"
    echo ""
    echo "🔍 Para ver el contenido del vault:"
    echo "   ansible-vault view $VAULT_FILE"
    echo ""
    echo "✏️  Para editar el vault:"
    echo "   ansible-vault edit $VAULT_FILE"
    echo ""
    echo "🔓 Para desencriptar temporalmente:"
    echo "   ansible-vault decrypt $VAULT_FILE"
    echo ""
    echo "🔒 Para volver a encriptar:"
    echo "   ansible-vault encrypt $VAULT_FILE"
    echo ""
    echo "⚠️  IMPORTANTE: ¡Nunca subas el archivo desencriptado a Git!"
}

# Función principal
main() {
    echo "🚀 Iniciando configuración..."
    
    # Verificar que estamos en el directorio correcto
    if [[ ! -d "$ANSIBLE_DIR" ]]; then
        echo "❌ Error: Directorio $ANSIBLE_DIR no encontrado"
        exit 1
    fi
    
    cd "$ANSIBLE_DIR"
    
    # Crear directorio SSH si no existe
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    
    # Ejecutar pasos
    check_ssh_key
    create_vault_content
    encrypt_vault
    show_summary
    
    echo ""
    echo "🎯 ¡Configuración completada exitosamente!"
    echo "   Tu laboratorio ahora tiene seguridad real implementada."
}

# Verificar dependencias
command -v ansible-vault >/dev/null 2>&1 || {
    echo "❌ Error: ansible-vault no encontrado. Instala Ansible primero."
    exit 1
}

command -v openssl >/dev/null 2>&1 || {
    echo "❌ Error: openssl no encontrado. Instálalo primero."
    exit 1
}

# Ejecutar
main "$@"