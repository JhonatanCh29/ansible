#!/bin/bash
# Script para configurar vm_control usando el proyecto Ansible existente
# Ejecutar EN vm_control en el directorio del proyecto clonado

echo "🎛️ CONFIGURANDO VM_CONTROL CON PROYECTO EXISTENTE"
echo "================================================="

# 1. Verificar que estamos en el directorio correcto
if [ ! -f "playbook.yml" ] || [ ! -d "roles" ]; then
    echo "❌ Error: No estás en el directorio del proyecto Ansible"
    echo "📁 Clona primero: git clone https://github.com/JhonatanCh29/ansible.git"
    echo "📁 Luego ejecuta: cd ansible && ./scripts/configurar_vm_control.sh"
    exit 1
fi

echo "✅ Proyecto Ansible detectado"

# 2. Instalar herramientas si no están
echo "📦 Verificando herramientas..."
which ansible >/dev/null 2>&1 || {
    echo "Instalando Ansible..."
    sudo apt update
    sudo apt install -y ansible sshpass openssh-client
}

# 3. Generar clave SSH si no existe
echo "🔑 Configurando SSH..."
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "ansible@control" -f ~/.ssh/id_rsa -N ""
    echo "✅ Clave SSH generada"
else
    echo "✅ Clave SSH ya existe"
fi

# 4. Actualizar inventario con IPs actuales
echo "📝 Actualizando inventario con IPs del laboratorio..."
cat > inventory/hosts.yml << 'EOF'
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

# 5. Actualizar variables de grupo
echo "🔧 Actualizando variables de grupo..."
cat > inventory/group_vars/lab_academico.yml << 'EOF'
---
# Variables para el laboratorio académico
lab_network: "192.168.50.0/24"
lab_gateway: "192.168.50.1"
lab_dns: "8.8.8.8"

# Variables para automatización nivel 4
backup_enabled: true
monitoring_enabled: true
security_hardening: true
automation_level: 4
EOF

# 6. Crear ansible.cfg específico para este proyecto
echo "🔐 Configurando ansible.cfg para el proyecto..."
cat > ansible.cfg << 'EOF'
[defaults]
inventory = inventory/hosts.yml
host_key_checking = False
timeout = 30
remote_user = jhonatan
roles_path = roles
retry_files_enabled = False

[inventory]
enable_plugins = yaml

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
control_path_dir = ~/.ansible/cp
EOF

# 7. Crear script para copiar SSH keys usando el proyecto
echo "🔑 Creando script de SSH keys en el proyecto..."
cat > scripts/copiar_ssh_keys.sh << 'EOF'
#!/bin/bash
echo "🔑 COPIANDO CLAVES SSH PARA EL PROYECTO ANSIBLE"
echo "=============================================="

echo "Clave SSH pública:"
cat ~/.ssh/id_rsa.pub
echo ""

echo "1. Copiando a vm_jhonatan (192.168.50.1)..."
ssh-copy-id -o StrictHostKeyChecking=no jhonatan@192.168.50.1

echo ""
echo "2. Copiando a mint_jhonatan (192.168.50.20)..."
ssh-copy-id -o StrictHostKeyChecking=no jhonatan@192.168.50.20

echo ""
echo "✅ Claves SSH copiadas"
echo "🧪 Probando conectividad Ansible..."
ansible all -m ping
EOF

chmod +x scripts/copiar_ssh_keys.sh

# 8. Crear playbook de verificación de nivel 4
echo "📋 Creando playbook de verificación nivel 4..."
cat > playbooks/verificar_nivel4.yml << 'EOF'
---
- name: 🎯 Verificación completa de implementación Nivel 4
  hosts: lab_academico
  become: yes
  gather_facts: yes
  
  tasks:
    - name: 📊 Información del sistema
      debug:
        msg: |
          🖥️  Sistema: {{ inventory_hostname }}
          🔧 OS: {{ ansible_facts['distribution'] | default('Unknown') }}
          🌐 IP: {{ ansible_facts['default_ipv4']['address'] | default('No IP') }}
          ⚡ Uptime: {{ ansible_facts['uptime_seconds'] | default(0) }}s
          
    - name: 🔍 Verificar roles aplicados
      stat:
        path: "/var/log/ansible-{{ item }}.log"
      register: role_check
      loop:
        - almacenamiento_sistemas
        - procesos_servicios  
        - red_lab
        - tareas_automatizadas
        - usuarios_permisos
        
    - name: 📋 Estado de roles nivel 4
      debug:
        msg: |
          📦 Roles implementados:
          {% for item in role_check.results %}
          - {{ item.item }}: {{ 'SÍ' if item.stat.exists else 'NO' }}
          {% endfor %}
EOF

# 9. Verificar conectividad básica
echo ""
echo "📊 VERIFICANDO CONECTIVIDAD BÁSICA:"
echo "=================================="

ping -c 2 192.168.50.1 >/dev/null 2>&1 && echo "✅ vm_jhonatan (192.168.50.1)" || echo "❌ vm_jhonatan"
ping -c 2 192.168.50.20 >/dev/null 2>&1 && echo "✅ mint_jhonatan (192.168.50.20)" || echo "❌ mint_jhonatan"

echo ""
echo "🎉 PROYECTO CONFIGURADO PARA VM_CONTROL"
echo "======================================="
echo ""
echo "📋 PRÓXIMOS PASOS:"
echo "1. Copiar SSH keys: ./scripts/copiar_ssh_keys.sh"
echo "2. Probar conexión: ansible all -m ping"  
echo "3. Aplicar roles nivel 4: ansible-playbook playbook.yml"
echo "4. Verificar implementación: ansible-playbook playbooks/verificar_nivel4.yml"
echo ""
echo "📁 ARCHIVOS DEL PROYECTO ACTUALIZADOS:"
echo "- inventory/hosts.yml (IPs del laboratorio)"
echo "- inventory/group_vars/lab_academico.yml"  
echo "- ansible.cfg (configuración optimizada)"
echo "- scripts/copiar_ssh_keys.sh"
echo "- playbooks/verificar_nivel4.yml"
echo ""
echo "🔑 CLAVE SSH PÚBLICA:"
cat ~/.ssh/id_rsa.pub
echo ""
echo "✅ ¡LISTO PARA IMPLEMENTAR ANSIBLE NIVEL 4!"