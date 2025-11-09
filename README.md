# Proyecto Ansible

Este repositorio contiene playbooks y roles para levantar un laboratorio de red
con una VM que actúa como router/DHCP (`vm_jhonatan`) y clientes (`mint_jhonatan`).

Pasos rápidos para preparar el nodo de control (ejecutar en la VM de control):

1. Ejecutar el script de bootstrap para instalar dependencias en la VM de control:

	./bootstrap_control.sh

2. Crear/usar una clave SSH y copiar la pública a las VMs objetivo:

	# desde la VM de control
	cat ~/.ssh/id_ed25519.pub
	# añadir esa clave en /home/jhonatan/.ssh/authorized_keys en cada VM

3. Uso de Ansible Vault (recomendado para contraseñas)

	- No guardes contraseñas en texto plano en el repo. Para crear un archivo
	  cifrado con Ansible Vault en la máquina de control:

	  ansible-vault create group_vars/all/vault.yml

	- Dentro de ese archivo define variables como:

	  ansible_ssh_pass_vm_jhonatan: "qwe123$"

	- Para ejecutar un playbook con un vault protegido, Ansible pedirá la
	  passphrase. Alternativamente puedes usar --vault-password-file en CI.

4. Comprobaciones recomendadas (máquina control):

	# activar venv si lo creaste con bootstrap_control.sh
	source ~/.ansible-venv/bin/activate
	ansible-lint .
	ansible-playbook playbooks/setup_network_server.yml -i inventory/hosts.yml --syntax-check

5. Notas sobre usuarios y become

	Este repositorio asume que las VMs tienen un usuario `jhonatan` (no root)
	y que se usará `become` para tareas con privilegios. Edita `inventory/hosts.yml`
	si tus usuarios se llaman distinto.

