#!/bin/bash
# Script para eliminar errores de vault y configurar SSH correctamente
# Ejecutar EN vm_control en el directorio del proyecto

echo "🔧 SOLUCIONANDO ERROR DE VAULT Y CONFIGURANDO SSH"
echo "================================================="

# 1. Limpiar cualquier referencia a vault
echo "🧹 Limpiando archivos problemáticos..."
rm -f inventory/group_vars/all.yml 2>/dev/null
rm -f inventory/vault.yml 2>/dev/null
rm -f .vault_pass 2>/dev/null

# 2. Crear inventario completamente limpio
echo "📝 Creando inventario SIN vault..."
cat > inventory/hosts.yml << 'EOF'
---
all:
  children:
    lab_academico:
      hosts:
        vm_jhonatan:
          ansible_host: 192.168.50.1
          ansible_user: jhonatan
        mint_jhonatan:
          ansible_host: 192.168.50.20
          ansible_user: jhonatan
      vars:
        ansible_python_interpreter: /usr/bin/python3
        ansible_become: yes
        ansible_become_method: sudo
EOF

# 3. Actualizar group_vars sin referencias problemáticas
echo "🔧 Actualizando group_vars..."
cat > inventory/group_vars/lab_academico.yml << 'EOF'
---
# Variables básicas para el laboratorio
lan_interface: "ens34"
wan_interface: "ens35"
lan_gateway_ip: "192.168.50.1"
lan_dhcp_start: "192.168.50.10"
lan_dhcp_end: "192.168.50.50"
dhcp_lease_time: "12h"
dns_forwarders:
  - "8.8.8.8"
  - "8.8.4.4"

# Variables para Nivel 4
logs_dir: "/var/log/lab"
admin_user: "jhonatan"
monitoring_enabled: true
backup_enabled: true
auto_update_enabled: true
EOF

# 4. Crear ansible.cfg sin vault
echo "⚙️ Configurando ansible.cfg..."
cat > ansible.cfg << 'EOF'
[defaults]
inventory = inventory/hosts.yml
host_key_checking = False
timeout = 30
remote_user = jhonatan
roles_path = roles
retry_files_enabled = False

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
control_path_dir = ~/.ansible/cp
EOF

# 5. Generar nueva clave SSH si no existe
echo "🔑 Configurando SSH..."
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "ansible@control" -f ~/.ssh/id_rsa -N ""
    echo "✅ Nueva clave SSH generada"
else
    echo "✅ Clave SSH existe"
fi

# 6. Mostrar la clave pública
echo ""
echo "🔑 CLAVE SSH PÚBLICA (copia esto):"
echo "=================================="
cat ~/.ssh/id_rsa.pub
echo "=================================="
echo ""

# 7. Instrucciones manuales para copiar SSH
echo "📋 INSTRUCCIONES PARA COPIAR SSH MANUALMENTE:"
echo "============================================"
echo ""
echo "En vm_jhonatan (192.168.50.1), ejecuta:"
echo "mkdir -p ~/.ssh"
echo "echo '$(cat ~/.ssh/id_rsa.pub)' >> ~/.ssh/authorized_keys"
echo "chmod 600 ~/.ssh/authorized_keys"
echo "chmod 700 ~/.ssh"
echo ""
echo "En mint_jhonatan (192.168.50.20), ejecuta:"
echo "mkdir -p ~/.ssh"  
echo "echo '$(cat ~/.ssh/id_rsa.pub)' >> ~/.ssh/authorized_keys"
echo "chmod 600 ~/.ssh/authorized_keys"
echo "chmod 700 ~/.ssh"
echo ""

# 8. Crear script de prueba simple
echo "🧪 Creando script de prueba..."
cat > test_simple.sh << 'EOF'
#!/bin/bash
echo "🧪 PROBANDO CONECTIVIDAD SIMPLE"
echo "==============================="

echo "1. Ping básico:"
ping -c 2 192.168.50.1 && echo "✅ vm_jhonatan accesible" || echo "❌ vm_jhonatan"
ping -c 2 192.168.50.20 && echo "✅ mint_jhonatan accesible" || echo "❌ mint_jhonatan"

echo ""
echo "2. SSH manual:"
echo "ssh jhonatan@192.168.50.1 'hostname'"
echo "ssh jhonatan@192.168.50.20 'hostname'"

echo ""
echo "3. Ansible ping:"
ansible all -m ping --ask-pass --ask-become-pass
EOF

chmod +x test_simple.sh

echo ""
echo "✅ CONFIGURACIÓN LIMPIA COMPLETADA"
echo "================================="
echo ""
echo "📋 PRÓXIMOS PASOS:"
echo "1. Copia manualmente la clave SSH a las otras VMs (instrucciones arriba)"
echo "2. O ejecuta: ssh-copy-id jhonatan@192.168.50.1"
echo "3. Y ejecuta: ssh-copy-id jhonatan@192.168.50.20" 
echo "4. Luego prueba: ansible all -m ping"
echo ""
echo "🔧 Si persisten errores, ejecuta: ./test_simple.sh"