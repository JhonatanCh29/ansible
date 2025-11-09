Setup network server playbook
----------------------------

This folder contains `setup_network_server.yml` which applies the `red_lab` role.

Before running:

1. Update your inventory so the host or group you target exists. The example playbook targets the group `lab_academico`.
2. Edit `inventory/group_vars/lab_academico.yml` (or host_vars) to set `lan_interface` and `wan_interface` to the correct interface names inside the VM.
3. Ensure the control node (your Ansible host) can SSH to the target VM as configured in `inventory/hosts.yml`.

Run the playbook:

```bash
ansible-playbook -i inventory/hosts.yml playbooks/setup_network_server.yml
```

After run, verify on the server:

- `ip addr show {{ lan_interface }}` and `ip addr show {{ wan_interface }}`
- `iptables -t nat -L -n -v` should show a MASQUERADE rule
- `systemctl status dnsmasq`
- from a LAN VM, obtain DHCP and check `ip route` and DNS resolution
