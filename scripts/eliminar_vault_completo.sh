#!/bin/bash
# Eliminación completa de referencias a vault
# Ejecutar EN vm_control

echo "🗑️ ELIMINANDO COMPLETAMENTE REFERENCIAS A VAULT"
echo "==============================================="

# 1. Buscar y eliminar TODOS los archivos relacionados con vault
echo "🔍 Buscando archivos problemáticos..."
find . -name "*vault*" -type f -delete 2>/dev/null || true
find . -name "*.vault" -type f -delete 2>/dev/null || true
find . -name ".vault_pass*" -type f -delete 2>/dev/null || true

# 2. Eliminar directorios problemáticos
rm -rf inventory/group_vars/all.yml 2>/dev/null || true
rm -rf .ansible 2>/dev/null || true

# 3. Crear inventario completamente nuevo
echo "📝 Creando inventario completamente limpio..."
rm -f inventory/hosts.yml
cat > inventory/hosts.yml << 'EOF'
vm_jhonatan ansible_host=192.168.50.1 ansible_user=jhonatan
mint_jhonatan ansible_host=192.168.50.20 ansible_user=jhonatan

[lab_academico]
vm_jhonatan
mint_jhonatan

[lab_academico:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_become=yes
ansible_become_method=sudo
EOF

# 4. Crear ansible.cfg minimalista
echo "⚙️ Creando ansible.cfg minimalista..."
cat > ansible.cfg << 'EOF'
[defaults]
inventory = inventory/hosts.yml
host_key_checking = False
remote_user = jhonatan
timeout = 30

[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no
EOF

# 5. Eliminar variables problemáticas de group_vars
echo "🧹 Limpiando group_vars..."
cat > inventory/group_vars/lab_academico.yml << 'EOF'
# Variables básicas sin vault
lan_interface: "ens34"
admin_user: "jhonatan"
monitoring_enabled: true
backup_enabled: true
EOF

# 6. Crear test directo sin usar ansible-playbook
echo "🧪 Creando test directo..."
cat > test_directo.sh << 'EOF'
#!/bin/bash
echo "🧪 TEST DIRECTO SIN VAULT"
echo "========================"

echo "1. Conectividad SSH directa:"
ssh -o StrictHostKeyChecking=no jhonatan@192.168.50.1 "hostname" 2>/dev/null && echo "✅ vm_jhonatan SSH OK" || echo "❌ vm_jhonatan SSH falla"
ssh -o StrictHostKeyChecking=no jhonatan@192.168.50.20 "hostname" 2>/dev/null && echo "✅ mint_jhonatan SSH OK" || echo "❌ mint_jhonatan SSH falla"

echo ""
echo "2. Ansible ping simple:"
ansible vm_jhonatan -m ping -u jhonatan
echo ""
ansible mint_jhonatan -m ping -u jhonatan

echo ""
echo "3. Ansible ad-hoc command:"
ansible lab_academico -m setup -a "filter=ansible_hostname" -u jhonatan
EOF

chmod +x test_directo.sh

# 7. Test inmediato
echo ""
echo "🧪 PROBANDO CONECTIVIDAD INMEDIATA:"
echo "==================================="

# SSH directo
echo "1. SSH directo a vm_jhonatan:"
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 jhonatan@192.168.50.1 "hostname" 2>/dev/null && echo "✅ SSH OK" || echo "❌ SSH falla"

echo ""
echo "2. SSH directo a mint_jhonatan:"  
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 jhonatan@192.168.50.20 "hostname" 2>/dev/null && echo "✅ SSH OK" || echo "❌ SSH falla"

echo ""
echo "3. Ansible ping directo (sin playbook):"
ansible vm_jhonatan -m ping -u jhonatan 2>/dev/null || echo "Ansible ping falló"

echo ""
echo "✅ VAULT ELIMINADO COMPLETAMENTE"
echo "==============================="
echo ""
echo "📋 PRUEBAS MANUALES:"
echo "1. ./test_directo.sh"
echo "2. ansible all -m ping"
echo "3. Si funciona: ansible-playbook playbook.yml"