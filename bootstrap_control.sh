#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script for the control VM (Linux Mint / Debian family)
# Usage: run this on the control VM after cloning the repo
#   ./bootstrap_control.sh

echo "==> Actualizando paquetes e instalando dependencias del sistema"
sudo apt update
sudo apt install -y software-properties-common apt-transport-https ca-certificates curl gnupg lsb-release

echo "==> Instalando paquetes esenciales"
sudo apt install -y python3 python3-venv python3-pip git ansible sshpass vim

echo "==> Instalando herramientas Python útiles dentro de un virtualenv (~/.ansible-venv)"
# Crear virtualenv en el home del usuario 'control' y usarlo para instalar linters
python3 -m venv ~/.ansible-venv
source ~/.ansible-venv/bin/activate
pip install --upgrade pip
pip install ansible-lint yamllint
echo "==> Instalando ansible-core y colecciones útiles en el virtualenv"
pip install ansible-core
# instalar una colección muy usada (ajusta si no la necesitas)
~/.ansible-venv/bin/ansible-galaxy collection install community.general || true
deactivate
echo "Herramientas instaladas en ~/.ansible-venv. Úsalas con: source ~/.ansible-venv/bin/activate && ansible-lint"

echo "==> Creando estructura recomendada del repo (si no existe)"
[ -d ~/ansible ] || mkdir -p ~/ansible

echo "==> Asegurando SSH key para el usuario actual"
[ -d ~/.ssh ] || mkdir -m 700 ~/.ssh
if [ ! -f ~/.ssh/id_ed25519 ]; then
  ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "control@lab"
  echo "Clave SSH generada en ~/.ssh/id_ed25519"
else
  echo "Clave SSH ya existe en ~/.ssh/id_ed25519"
fi

echo "==> Recomendación: Añade la clave pública (~/.ssh/id_ed25519.pub) a los hosts objetivo para SSH sin contraseña"

echo "==> Resultado: entorno de control listo. Ejecuta desde el repo: ansible-playbook -i inventory/hosts.yml playbooks/setup_network_server.yml"

echo "==> Nota de seguridad: no almacenes contraseñas en texto plano ni dentro del repositorio. Usa archivos vault o claves SSH."

exit 0
