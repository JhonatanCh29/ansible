#!/bin/bash
# Script simple para configurar vm_control como centro Ansible
# Ejecutar EN vm_control

echo "🎛️ CONFIGURANDO VM_CONTROL COMO CENTRO ANSIBLE"
echo "=============================================="

# 1. Instalar herramientas
echo "📦 Instalando herramientas necesarias..."
sudo apt update
sudo apt install -y ansible sshpass openssh-client git curl python3-pip

# 2. Crear directorio de trabajo
echo "📁 Creando estructura de directorios..."
mkdir -p ~/ansible/inventory/group_vars
mkdir -p ~/ansible/playbooks
mkdir -p ~/.ssh

# 3. Generar clave SSH
echo "🔑 Configurando SSH..."
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "ansible@control" -f ~/.ssh/id_rsa -N ""
    echo "✅ Clave SSH generada"
else
    echo "✅ Clave SSH ya existe"
fi

# 4. Crear inventario simple
echo "📝 Creando inventario..."
cat > ~/ansible/inventory/hosts.yml << 'EOF'
---
all:
  children:
    lab_academico:
      hosts:
        vm_jhonatan:
          ansible_host: 192.168.50.1
          ansible_user: jhonatan
          vm_role: router
          os_type: fedora
        mint_jhonatan:
          ansible_host: 192.168.50.20
          ansible_user: jhonatan
          vm_role: client
          os_type: mint
      vars:
        ansible_python_interpreter: /usr/bin/python3
        ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
EOF

# 5. Crear ansible.cfg
echo "🔐 Configurando ansible.cfg..."
cat > ~/ansible/ansible.cfg << 'EOF'
[defaults]
inventory = inventory/hosts.yml
host_key_checking = False
timeout = 30
remote_user = jhonatan

[inventory]
enable_plugins = yaml

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
control_path_dir = ~/.ansible/cp
EOF

# 6. Crear script para copiar SSH keys
echo "🔑 Creando script para copiar claves SSH..."
cat > ~/ansible/copiar_ssh_keys.sh << 'EOF'
#!/bin/bash
echo "🔑 COPIANDO CLAVES SSH A LAS VMs DEL LABORATORIO"
echo "=============================================="

echo "Clave SSH pública a copiar:"
cat ~/.ssh/id_rsa.pub
echo ""

echo "1. Copiando a vm_jhonatan (192.168.50.1)..."
ssh-copy-id -o StrictHostKeyChecking=no jhonatan@192.168.50.1

echo ""
echo "2. Copiando a mint_jhonatan (192.168.50.20)..."
ssh-copy-id -o StrictHostKeyChecking=no jhonatan@192.168.50.20

echo ""
echo "✅ Claves SSH copiadas a todas las VMs"
echo "🧪 Probando conectividad..."

cd ~/ansible
ansible all -m ping
EOF

chmod +x ~/ansible/copiar_ssh_keys.sh

# 7. Crear playbook de prueba
echo "🧪 Creando playbook de prueba..."
cat > ~/ansible/test_conectividad.yml << 'EOF'
---
- name: 🧪 Prueba de conectividad del laboratorio
  hosts: lab_academico
  gather_facts: yes
  tasks:
    - name: 📊 Obtener información del sistema
      raw: |
        echo "=== INFORMACIÓN DEL SISTEMA ==="
        hostname
        whoami
        ip addr show ens34 | grep inet
        uptime
      register: system_info
      
    - name: 📋 Mostrar información
      debug:
        msg: |
          Sistema: {{ inventory_hostname }}
          Info: {{ system_info.stdout_lines }}
EOF

# 8. Verificar conectividad
echo ""
echo "📊 VERIFICANDO CONECTIVIDAD:"
echo "=========================="

echo "1. Ping a vm_jhonatan (192.168.50.1):"
if ping -c 2 192.168.50.1 >/dev/null 2>&1; then
    echo "✅ vm_jhonatan accesible"
else
    echo "❌ vm_jhonatan NO accesible"
fi

echo ""
echo "2. Ping a mint_jhonatan (192.168.50.20):"
if ping -c 2 192.168.50.20 >/dev/null 2>&1; then
    echo "✅ mint_jhonatan accesible"
else
    echo "❌ mint_jhonatan NO accesible"
fi

echo ""
echo "🎉 VM_CONTROL CONFIGURADA EXITOSAMENTE"
echo "====================================="
echo ""
echo "📋 PRÓXIMOS PASOS:"
echo "1. Ejecutar: ~/ansible/copiar_ssh_keys.sh"
echo "2. Probar: cd ~/ansible && ansible all -m ping"
echo "3. Ejecutar: ansible-playbook test_conectividad.yml"
echo ""
echo "📁 ARCHIVOS CREADOS:"
echo "- ~/ansible/inventory/hosts.yml"
echo "- ~/ansible/ansible.cfg"
echo "- ~/ansible/copiar_ssh_keys.sh"
echo "- ~/ansible/test_conectividad.yml"
echo ""
echo "🔑 CLAVE SSH PÚBLICA:"
echo "===================="
cat ~/.ssh/id_rsa.pub
echo ""
echo "✅ LABORATORIO ANSIBLE LISTO"