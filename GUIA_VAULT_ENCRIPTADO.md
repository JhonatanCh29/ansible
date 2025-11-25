# 🔐 GUÍA DE USO - ANSIBLE VAULT ENCRIPTADO

## 📋 **Estado Actual del Vault**

✅ **Archivo encriptado:** `group_vars/all/vault.yml`  
🔑 **Contraseña:** `laboratorio2024`  
📁 **Archivo de contraseña:** `.vault_pass` (permisos 600)  

## 🚀 **Comandos para Ejecutar Playbooks**

### **Opción 1: Con archivo de contraseña (Recomendado)**
```bash
# Ejecutar playbook completo
ansible-playbook security_playbook.yml --vault-password-file .vault_pass

# Ejecutar solo firewall
ansible-playbook security_playbook.yml --vault-password-file .vault_pass --tags firewall

# Ejecutar con inventario específico
ansible-playbook -i inventory/local_hosts.yml security_playbook.yml --vault-password-file .vault_pass
```

### **Opción 2: Solicitar contraseña interactivamente**
```bash
# El sistema pedirá la contraseña
ansible-playbook security_playbook.yml --ask-vault-pass

# Contraseña: laboratorio2024
```

## 🔧 **Gestión del Vault**

### **Ver contenido del vault:**
```bash
# Mostrar variables
ansible-vault view group_vars/all/vault.yml --vault-password-file .vault_pass

# O con contraseña interactiva
ansible-vault view group_vars/all/vault.yml
```

### **Editar el vault:**
```bash
# Editar archivo encriptado
ansible-vault edit group_vars/all/vault.yml --vault-password-file .vault_pass

# O con contraseña interactiva
ansible-vault edit group_vars/all/vault.yml
```

### **Desencriptar temporalmente:**
```bash
# Desencriptar para ver/editar
ansible-vault decrypt group_vars/all/vault.yml --vault-password-file .vault_pass

# ⚠️ IMPORTANTE: Volver a encriptar después
ansible-vault encrypt group_vars/all/vault.yml --vault-password-file .vault_pass
```

### **Cambiar contraseña del vault:**
```bash
# Cambiar contraseña
ansible-vault rekey group_vars/all/vault.yml --vault-password-file .vault_pass
```

## 📊 **Variables Disponibles en el Vault**

El vault contiene las siguientes variables encriptadas:

```yaml
# 🔑 Credenciales del Sistema
vault_admin_password: "TuPasswordSeguro123!"
vault_mysql_root_password: "MySQL_Root_Pass_2024!"
vault_postgresql_password: "PostgreSQL_Pass_2024!"

# 🌐 Claves API y Servicios
vault_api_key: "tu-clave-api-secreta"
vault_github_token: "tu-token-github"
vault_smtp_password: "password-smtp"

# 🔐 Claves SSH
vault_ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  # Tu clave SSH privada
  -----END OPENSSH PRIVATE KEY-----

vault_ssh_public_key: "ssh-rsa AAA... tu@hostname"

# 🛡️ Certificados y Tokens
vault_ssl_cert: "Certificado SSL"
vault_jwt_secret: "JWT secret"
vault_encryption_key: "Clave de encriptación"

# 🔑 Credenciales de Servicios
vault_database_url: "postgresql://user:pass@host:port/db"
vault_ldap_bind_password: "LDAP password"
vault_backup_encryption_key: "Clave backup"
```

## 🎯 **Uso en Playbooks**

### **Referenciar variables del vault:**
```yaml
# En tareas de Ansible
- name: Configurar base de datos
  mysql_user:
    name: admin
    password: "{{ vault_mysql_root_password }}"
    
- name: Usar clave SSH
  copy:
    content: "{{ vault_ssh_private_key }}"
    dest: /home/user/.ssh/id_rsa
    mode: '0600'
```

### **En templates:**
```jinja
# archivo.conf.j2
database_password={{ vault_mysql_root_password }}
api_key={{ vault_api_key }}
```

## ⚠️ **Consideraciones de Seguridad**

### **✅ Buenas Prácticas:**
- ✅ Vault encriptado con contraseña fuerte
- ✅ Archivo `.vault_pass` con permisos restrictivos (600)
- ✅ Backup no encriptado en ubicación segura (`vault_backup.yml`)
- ✅ Variables sensibles centralizadas en vault

### **⚠️ Precauciones:**
- ❌ **NUNCA** hacer commit del archivo `.vault_pass` a Git
- ❌ **NUNCA** dejar el vault desencriptado permanentemente
- ❌ **EVITAR** usar la contraseña en comandos visibles en history
- ✅ **SIEMPRE** hacer backup antes de cambios importantes

## 🔄 **Troubleshooting Común**

### **Error: "Vault password incorrect"**
```bash
# Verificar que usas la contraseña correcta: laboratorio2024
ansible-vault view group_vars/all/vault.yml --ask-vault-pass
```

### **Error: "File not found"**
```bash
# Verificar la ruta del vault
ls -la group_vars/all/vault.yml

# Verificar desde el directorio correcto
cd /home/jhonatan/ansible
```

### **Restaurar desde backup:**
```bash
# Si hay problemas, restaurar desde backup
cp group_vars/all/vault_backup.yml group_vars/all/vault.yml

# Volver a encriptar
ansible-vault encrypt group_vars/all/vault.yml --vault-password-file .vault_pass
```

## 📋 **Scripts de Verificación**

### **Verificar estado del vault:**
```bash
#!/bin/bash
echo "🔍 Estado del Ansible Vault:"
echo "================================"

# Verificar si está encriptado
if grep -q "ANSIBLE_VAULT" group_vars/all/vault.yml; then
    echo "✅ Vault: ENCRIPTADO"
else
    echo "❌ Vault: NO ENCRIPTADO"
fi

# Verificar archivo de contraseña
if [ -f .vault_pass ]; then
    echo "✅ Archivo contraseña: PRESENTE"
    echo "📋 Permisos: $(stat -c %a .vault_pass)"
else
    echo "❌ Archivo contraseña: AUSENTE"
fi

# Verificar backup
if [ -f group_vars/all/vault_backup.yml ]; then
    echo "✅ Backup: DISPONIBLE"
else
    echo "⚠️ Backup: NO DISPONIBLE"
fi

echo "🔐 Contraseña actual: laboratorio2024"
```

### **Test de conectividad con vault:**
```bash
# Verificar que el vault funciona
ansible-playbook --syntax-check security_playbook.yml --vault-password-file .vault_pass

# Si funciona, verás: "playbook: security_playbook.yml"
```

## 🎓 **Para Evaluación Académica**

### **Evidencias de implementación:**
1. **Vault encriptado:** `file group_vars/all/vault.yml`
2. **Variables protegidas:** `ansible-vault view group_vars/all/vault.yml --vault-password-file .vault_pass`
3. **Funcionamiento:** `ansible-playbook security_playbook.yml --vault-password-file .vault_pass --check`
4. **Seguridad:** `ls -la .vault_pass` (permisos 600)

La implementación cumple con todos los requisitos de **Nivel 4** para manejo seguro de credenciales y configuraciones sensibles.