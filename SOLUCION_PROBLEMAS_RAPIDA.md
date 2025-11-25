# ⚡ GUÍA RÁPIDA DE TROUBLESHOOTING - PROBLEMAS COMUNES

## 🚨 Soluciones Rápidas a Problemas Frecuentes

### **❌ PROBLEMA: "No module named ansible"**
```bash
# SOLUCIÓN:
sudo apt update
sudo apt install -y ansible python3-pip
pip3 install ansible --user

# Verificar instalación:
ansible --version
```

### **❌ PROBLEMA: "Permission denied (publickey)"**
```bash
# SOLUCIÓN - Configurar SSH:
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Probar:
ssh localhost whoami
```

### **❌ PROBLEMA: "sudo: a password is required"**
```bash
# SOLUCIÓN - Agregar --ask-become-pass:
ansible-playbook security_playbook.yml --ask-become-pass

# O configurar sudo sin contraseña (solo para lab):
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
```

### **❌ PROBLEMA: "Failed to connect to the host via ssh"**
```bash
# SOLUCIÓN - Usar inventario local:
cat > inventory/local_hosts.yml << EOF
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

# Usar este inventario:
ansible-playbook -i inventory/local_hosts.yml security_playbook.yml
```

### **❌ PROBLEMA: "Package 'clamav-daemon' has no installation candidate"**
```bash
# SOLUCIÓN - Actualizar repositorios:
sudo apt update
sudo apt install -y software-properties-common
sudo apt-add-repository universe
sudo apt update

# Reinstalar:
sudo apt install -y clamav clamav-daemon
```

### **❌ PROBLEMA: "Vault password is required"**
```bash
# SOLUCIÓN - Usar vault sin encriptar temporalmente:
cp group_vars/all/vault.yml group_vars/all/vault_backup.yml

# O crear archivo de contraseña:
echo "tu_password_vault" > .vault_pass
ansible-playbook security_playbook.yml --vault-password-file .vault_pass
```

## 🔄 **REINICIO COMPLETO - Si Todo Falla**

```bash
# 1. Limpiar instalación anterior
sudo apt autoremove --purge -y ansible clamav* fail2ban auditd
sudo rm -rf ~/.ansible
sudo rm -rf /etc/fail2ban/jail.local
sudo rm -rf /etc/sudoers.d/lab-users

# 2. Reinstalar desde cero
sudo apt update && sudo apt upgrade -y
sudo apt install -y ansible python3 git

# 3. Reclonar proyecto
cd ~ && rm -rf ansible
git clone https://github.com/JhonatanCh29/ansible.git
cd ansible

# 4. Ejecutar implementación básica
ansible-playbook -i inventory/local_hosts.yml security_playbook.yml --ask-become-pass -v
```

## 🆘 **COMANDO DE EMERGENCIA - VERIFICACIÓN RÁPIDA**

```bash
# Ejecutar para diagnóstico inmediato:
echo "🔍 DIAGNÓSTICO RÁPIDO DEL SISTEMA"
echo "================================"
echo "Ansible: $(ansible --version 2>/dev/null | head -1 || echo 'NO INSTALADO')"
echo "Python: $(python3 --version 2>/dev/null || echo 'NO INSTALADO')"
echo "SSH Local: $(ssh -o ConnectTimeout=2 localhost 'echo OK' 2>/dev/null || echo 'FALLA')"
echo "Sudo: $(sudo -n whoami 2>/dev/null || echo 'REQUIERE CONTRASEÑA')"
echo "Internet: $(ping -c1 google.com >/dev/null 2>&1 && echo 'OK' || echo 'SIN CONEXIÓN')"
echo "Espacio: $(df -h / | awk 'NR==2 {print $4}') libre"
echo ""
echo "SERVICIOS OBJETIVO:"
systemctl is-active clamav-daemon fail2ban auditd ufw ssh 2>/dev/null || echo "Servicios no configurados"
```