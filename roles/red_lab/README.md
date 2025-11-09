Role red_lab
----------------
This role configures a Fedora/Ubuntu-based VM to act as the lab network server:

- Installs and configures dnsmasq for DHCP and DNS forwarding
- Enables IP forwarding
- Adds a NAT (MASQUERADE) iptables rule so LAN hosts can reach the Internet via the WAN interface
- Installs a small systemd unit to restore iptables NAT rule on boot

IMPORTANT: Update interface names and IP ranges in `vars/main.yml` or provide group/host vars in your inventory.

Variables you should set (examples):

- `lan_interface`: interface connected to the lab LAN (e.g. `ens192` or `eth1`)
- `wan_interface`: interface connected to Internet/VM Network (e.g. `ens33`)
- `lan_gateway_ip`: the static IP to give this server in the LAN (gateway for DHCP clients)
- `lan_dhcp_start`, `lan_dhcp_end`: DHCP pool

Use the playbook `playbooks/setup_network_server.yml` to apply this role to your lab server host/group.
