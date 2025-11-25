# 🔐 GUÍA DE SEGURIDAD PARA CLAVES PRIVADAS EN ANSIBLE

## ¿Por qué es seguro usar Ansible Vault?

### 🛡️ **Niveles de Seguridad:**

1. **Encriptación AES-256**: El estándar militar para protección de datos
2. **Claves nunca en texto plano**: Solo existen encriptadas en el repositorio  
3. **Control de acceso**: Solo quien tiene la contraseña puede desencriptar
4. **Separación de secretos**: Las claves están separadas del código

## 📋 **Opciones para Configurar Claves Reales**

### **Opción 1: Script Automático (Recomendado)**
```bash
# Ejecutar el script que creé para ti
cd /home/jhonatan/ansible
./scripts/setup_vault.sh
```

**Qué hace:**
- ✅ Genera contraseñas seguras automáticamente
- ✅ Crea o usa claves SSH existentes  
- ✅ Encripta todo con Ansible Vault
- ✅ Te da las instrucciones finales

### **Opción 2: Manual - Usando tus claves existentes**
```bash
# 1. Si ya tienes claves SSH
cat ~/.ssh/id_rsa    # Copia esta clave privada

# 2. Editar el vault manualmente
ansible-vault edit group_vars/all/vault.yml

# 3. Reemplazar la sección vault_ssh_private_key con tu clave real
```

### **Opción 3: Generar nuevas claves específicas para Ansible**
```bash
# Generar clave dedicada para Ansible
ssh-keygen -t rsa -b 4096 -C "ansible@laboratorio" -f ~/.ssh/ansible_key

# Usar esa clave en el vault
ansible-vault edit group_vars/all/vault.yml
```

## 🔒 **Comandos Esenciales de Ansible Vault**

```bash
# Ver contenido encriptado (requiere contraseña)
ansible-vault view group_vars/all/vault.yml

# Editar archivo encriptado
ansible-vault edit group_vars/all/vault.yml

# Cambiar contraseña del vault
ansible-vault rekey group_vars/all/vault.yml

# Encriptar archivo existente
ansible-vault encrypt group_vars/all/vault.yml

# Desencriptar temporalmente (¡CUIDADO!)
ansible-vault decrypt group_vars/all/vault.yml
```

## ⚡ **Usar las claves en tus playbooks**

```yaml
# En tus tareas, referencia las variables del vault:
- name: Copiar clave SSH
  ansible.builtin.copy:
    content: "{{ vault_ssh_private_key }}"
    dest: /home/usuario/.ssh/id_rsa
    mode: '0600'
    
- name: Conectar con base de datos
  community.mysql.mysql_user:
    login_password: "{{ vault_mysql_root_password }}"
    name: app_user
    password: "{{ vault_admin_password }}"
```

## 🚨 **Buenas Prácticas de Seguridad**

### ✅ **SÍ hacer:**
- Usar contraseñas fuertes para el vault (12+ caracteres)
- Mantener backups seguros de la contraseña del vault
- Verificar que `.gitignore` excluye archivos desencriptados
- Rotar las contraseñas regularmente
- Usar claves SSH específicas para diferentes entornos

### ❌ **NO hacer:**
- Nunca subir archivos desencriptados a Git
- No compartir la contraseña del vault por medios inseguros
- No usar la misma contraseña para múltiples vaults
- No dejar archivos temporales desencriptados
- No usar claves SSH sin passphrase en producción

## 🎯 **¿Por qué esto es más seguro que otras alternativas?**

| Método | Seguridad | Facilidad | Recomendación |
|--------|-----------|-----------|---------------|
| **Ansible Vault** | 🟢 Alta | 🟢 Fácil | ✅ **Recomendado** |
| Variables de entorno | 🟡 Media | 🟢 Fácil | ⚠️ Para desarrollo |
| Archivos externos | 🟡 Media | 🔴 Complejo | ❌ No recomendado |
| Texto plano en Git | 🔴 Nula | 🟢 Fácil | ❌ **NUNCA** |

## 🚀 **Ejecutar con Vault**

```bash
# Ejecutar playbooks con vault
ansible-playbook -i inventory/hosts.ini security_playbook.yml --ask-vault-pass

# O crear archivo de contraseña (más cómodo)
echo "tu_password_vault" > .vault_pass
ansible-playbook -i inventory/hosts.ini security_playbook.yml --vault-password-file .vault_pass

# ¡Recuerda agregar .vault_pass a .gitignore!
echo ".vault_pass" >> .gitignore
```

## 🎉 **Resultado Final**

Una vez configurado tendrás:
- 🔐 **Todas las claves encriptadas** con AES-256
- 🔑 **Claves SSH reales** para conexión a servidores
- 🛡️ **Contraseñas generadas** automáticamente
- 📊 **Sistema listo** para evaluación académica
- 🎯 **Seguridad de nivel empresarial** en tu laboratorio

**¡Tu repositorio será seguro incluso si es público!** 🚀