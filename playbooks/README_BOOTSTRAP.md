Bootstrap control node
----------------------

This playbook and script prepare a Linux Mint (Debian/Ubuntu family) control VM to run Ansible playbooks.

Files added:

- `bootstrap_control.sh` - a small shell script to be run locally on the control VM. Installs apt packages and pip tools and generates an SSH key if missing.
- `playbooks/bootstrap_control.yml` - an equivalent Ansible local-playbook that performs the same actions.

How to use (choose one):

1) Shell script (quick):

```bash
# on the control VM, after cloning the repo
cd ~/ansible
chmod +x bootstrap_control.sh
./bootstrap_control.sh
```

2) Ansible playbook (idempotent, verbose):

```bash
# on the control VM, after cloning the repo
cd ~/ansible
ansible-playbook -c local playbooks/bootstrap_control.yml --ask-become-pass
```

After running either method:

- Copy the public key `~/.ssh/id_ed25519.pub` to the `authorized_keys` of your lab VMs (vm_jhonatan, mint_jhonatan) so the control node can SSH without password.
- Verify you can SSH from control to target VMs: `ssh ansible@<vm_ip>` (or the user specified in `inventory/hosts.yml`).

Security notes:

- The script does not change sudoers or store passwords. If you want passwordless sudo for the `control` user, add it manually with `visudo`.
- Avoid committing private keys into the repo.
