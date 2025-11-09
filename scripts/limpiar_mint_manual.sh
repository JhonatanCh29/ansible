#!/bin/bash
# INSTRUCCIONES PARA LIMPIAR DUPLICADOS EN MINT_JHONATAN
# Ejecutar estos comandos UNO POR UNO en la consola de mint_jhonatan

echo "🔥 PASO 1: Ver el problema actual"
echo "================================="
nmcli connection show
echo ""
ip addr show ens34

echo ""
echo "🗑️ PASO 2: Eliminar TODAS las conexiones ethernet duplicadas"
echo "==========================================================="

# Eliminar todas las conexiones que puedan estar duplicadas
sudo nmcli connection delete "Wired connection 1" 2>/dev/null || true
sudo nmcli connection delete "Wired connection 2" 2>/dev/null || true
sudo nmcli connection delete "Ethernet connection 1" 2>/dev/null || true
sudo nmcli connection delete "ethernet" 2>/dev/null || true
sudo nmcli connection delete "ens34" 2>/dev/null || true

echo ""
echo "⏸️ PASO 3: Parar NetworkManager y limpiar completamente"
echo "======================================================="
sudo systemctl stop NetworkManager
sleep 2

# Limpiar la interfaz físicamente
sudo ip link set ens34 down
sudo ip addr flush dev ens34
sudo ip route flush dev ens34

echo ""
echo "🔄 PASO 4: Reiniciar NetworkManager"
echo "==================================="
sudo systemctl start NetworkManager
sleep 5

echo ""
echo "✅ PASO 5: Crear UNA SOLA conexión nueva y limpia"
echo "================================================="
sudo nmcli connection add type ethernet con-name "lab-dhcp" ifname ens34 autoconnect yes
sudo nmcli connection modify "lab-dhcp" ipv4.method auto ipv6.method ignore
sudo nmcli connection up "lab-dhcp"

echo ""
echo "⏱️ PASO 6: Esperar obtención de IP..."
sleep 10

echo ""
echo "📊 PASO 7: Verificar resultado"
echo "=============================="
echo "Conexiones activas:"
nmcli connection show --active
echo ""
echo "Estado de ens34:"
ip addr show ens34
echo ""
echo "Probar conectividad:"
ping -c 3 192.168.50.1