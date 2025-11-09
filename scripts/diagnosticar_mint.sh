#!/bin/bash
# Script de diagnóstico y corrección para mint_jhonatan
# Ejecutar EN la consola de mint_jhonatan

echo "🔍 DIAGNÓSTICO DE CONECTIVIDAD MINT_JHONATAN"
echo "=============================================="

echo "📊 Estado actual de interfaces:"
ip addr show | grep -A5 -B1 "ens3"

echo ""
echo "📡 Conexiones NetworkManager:"
nmcli connection show

echo ""
echo "🌐 Tabla de rutas:"
ip route show

echo ""
echo "🧪 Probar conectividad directa con el router:"
ping -c 3 192.168.50.1 2>/dev/null || echo "❌ Sin conectividad con router"

echo ""
echo "🔧 INICIANDO CORRECCIÓN AGRESIVA..."
echo "=================================="

# Parar todos los servicios de red
echo "⏸️ Parando servicios de red..."
sudo systemctl stop NetworkManager
sudo systemctl stop networking 2>/dev/null || true
sudo killall dhclient 2>/dev/null || true

# Limpiar completamente ens34
echo "🧹 Limpieza completa de ens34..."
sudo ip link set ens34 down
sudo ip addr flush dev ens34
sudo ip route flush dev ens34

# Limpiar cache ARP
echo "🗑️ Limpiando cache ARP..."
sudo ip neigh flush all

# Reiniciar interfaz físicamente
echo "🔄 Reiniciando interfaz física..."
sudo ip link set ens34 down
sleep 3
sudo ip link set ens34 up
sleep 5

# Reiniciar NetworkManager
echo "🚀 Reiniciando NetworkManager..."
sudo systemctl start NetworkManager
sleep 8

# Forzar detección de red
echo "🔍 Forzando detección de red..."
sudo nmcli device connect ens34

# Crear conexión DHCP forzada
echo "📡 Creando conexión DHCP forzada..."
sudo nmcli connection delete lab-dhcp-clean 2>/dev/null || true
sudo nmcli connection add type ethernet con-name lab-dhcp-mint ifname ens34 autoconnect yes
sudo nmcli connection modify lab-dhcp-mint ipv4.method auto ipv6.method ignore
sudo nmcli connection modify lab-dhcp-mint connection.autoconnect-priority 999

# Activar conexión
echo "⚡ Activando conexión..."
sudo nmcli connection up lab-dhcp-mint

# Forzar DHCP manualmente
echo "🔧 Forzando DHCP manual..."
sudo dhclient -r ens34 2>/dev/null || true
sleep 3
sudo dhclient -v ens34

# Esperar y verificar
echo "⏱️ Esperando obtención de IP (20 segundos)..."
for i in {1..20}; do
    IP=$(ip addr show ens34 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    if [[ -n "$IP" ]] && [[ "$IP" != "127.0.0.1" ]] && [[ "$IP" == 192.168.50.* ]]; then
        echo "✅ IP obtenida: $IP"
        break
    fi
    echo "Intento $i/20: Esperando IP..."
    sleep 1
done

echo ""
echo "📊 VERIFICACIÓN FINAL:"
echo "===================="
echo "Estado de ens34:"
ip addr show ens34

echo ""
echo "Conexiones activas:"
nmcli connection show --active

echo ""
echo "Rutas:"
ip route show | grep ens34

echo ""
echo "🧪 Prueba de conectividad final:"
if ping -c 3 192.168.50.1 >/dev/null 2>&1; then
    echo "✅ ÉXITO: Conectividad con router OK"
    IP_OBTENIDA=$(ip addr show ens34 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    echo "✅ IP asignada: $IP_OBTENIDA"
    echo "✅ mint_jhonatan está conectado al laboratorio"
else
    echo "❌ ERROR: Sin conectividad con router"
    echo "🔧 Verificar conexión física entre VMs"
fi

echo ""
echo "🏁 DIAGNÓSTICO Y CORRECCIÓN COMPLETADO"
echo "======================================"