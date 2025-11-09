#!/bin/bash
# Script de primer arranque para configuración automática
# Colocar en /etc/rc.local o crear servicio systemd

MARKER_FILE="/var/log/network-configured"

# Solo ejecutar una vez
if [ -f "$MARKER_FILE" ]; then
    exit 0
fi

echo "Configurando red automáticamente..." | logger

# Detectar si es Fedora o Mint/Ubuntu
if command -v dnf &> /dev/null; then
    # Es Fedora - configurar como servidor
    dnf install -y NetworkManager git ansible-core
    nmcli connection add type ethernet ifname ens192 con-name lab-lan ipv4.method manual ipv4.addresses 192.168.50.1/24 connection.autoconnect yes
    nmcli connection add type ethernet ifname ens33 con-name wan-dhcp ipv4.method auto connection.autoconnect yes
    nmcli connection up lab-lan
    nmcli connection up wan-dhcp
    sysctl -w net.ipv4.ip_forward=1
    echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
    systemctl enable --now sshd
    echo "vm_jhonatan configurada automáticamente" | logger
elif command -v apt &> /dev/null; then
    # Es Ubuntu/Mint - configurar como cliente
    apt update && apt install -y network-manager git ansible
    nmcli connection add type ethernet ifname ens192 con-name lan-dhcp ipv4.method auto connection.autoconnect yes
    nmcli connection up lan-dhcp
    systemctl enable --now ssh
    echo "mint_jhonatan configurada automáticamente" | logger
fi

# Marcar como completado
touch "$MARKER_FILE"
echo "Red configurada automáticamente en $(date)" > "$MARKER_FILE"