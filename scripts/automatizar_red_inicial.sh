#!/bin/bash
# Script automatizado para configurar la red inicial de las VMs
# Este script debe ejecutarse desde la VM de control y usar acceso directo a las VMs

echo "🚀 CONFIGURACIÓN AUTOMATIZADA DE RED - LABORATORIO ANSIBLE"
echo "========================================================="
echo ""

# Verificar que estamos en la VM de control
if [ ! -f "ansible.cfg" ]; then
    echo "❌ ERROR: Ejecutar este script desde el directorio del repo Ansible"
    exit 1
fi

echo "📋 PASO 1: Preparar archivos necesarios para transferir..."

# Crear script para vm_jhonatan
cat > /tmp/config_vm_jhonatan.sh << 'EOF'
#!/bin/bash
echo "🔧 Configurando vm_jhonatan..."

# Instalar Ansible si no está (solo para esta configuración inicial)
if ! command -v ansible-playbook &> /dev/null; then
    if command -v dnf &> /dev/null; then
        sudo dnf install -y ansible-core
    else
        sudo apt update && sudo apt install -y ansible
    fi
fi

# Ejecutar configuración local
ansible-playbook -c local -i localhost, /tmp/configurar_red_vm_jhonatan.yml

echo "✅ vm_jhonatan configurada. Verificando conectividad..."
ip addr show
EOF

# Crear script para mint_jhonatan
cat > /tmp/config_mint_jhonatan.sh << 'EOF'
#!/bin/bash
echo "🔧 Configurando mint_jhonatan..."

# Instalar Ansible si no está
if ! command -v ansible-playbook &> /dev/null; then
    sudo apt update && sudo apt install -y ansible
fi

# Ejecutar configuración local
ansible-playbook -c local -i localhost, /tmp/configurar_red_mint_jhonatan.yml

echo "✅ mint_jhonatan configurada. Verificando conectividad..."
ip addr show
EOF

chmod +x /tmp/config_vm_jhonatan.sh
chmod +x /tmp/config_mint_jhonatan.sh

echo "📁 Scripts preparados en /tmp/"
echo ""

echo "📋 PASO 2: Instrucciones de ejecución"
echo "======================================"
echo ""
echo "🎯 Para automatizar completamente, ejecuta estos comandos:"
echo ""
echo "1️⃣  En la CONSOLA de vm_jhonatan (Fedora):"
echo "   # Descargar el repo y ejecutar configuración"
echo "   sudo dnf install -y git"
echo "   git clone https://github.com/JhonatanCh29/ansible.git"
echo "   cd ansible"
echo "   ansible-playbook -c local -i localhost, playbooks/configurar_red_vm_jhonatan.yml"
echo ""
echo "2️⃣  En la CONSOLA de mint_jhonatan (Linux Mint):"
echo "   # Descargar el repo y ejecutar configuración" 
echo "   sudo apt update && sudo apt install -y git"
echo "   git clone https://github.com/JhonatanCh29/ansible.git"
echo "   cd ansible"
echo "   ansible-playbook -c local -i localhost, playbooks/configurar_red_mint_jhonatan.yml"
echo ""
echo "3️⃣  Desde la VM de control, verificar conectividad:"
echo "   ping 192.168.50.1"
echo "   ssh jhonatan@192.168.50.1"
echo ""
echo "🔥 ALTERNATIVA: Si las VMs tienen acceso temporal a internet:"
echo "   Puedes usar cloud-init, pre-seeding o scripts de inicio automático"
echo ""
echo "========================================================="