#!/bin/bash
# Script AGRESIVO para LIMPIAR COMPLETAMENTE las interfaces ens34
# Version mejorada para casos problemáticos

echo "🔥 LIMPIEZA AGRESIVA DE INTERFACES DE RED"
echo "========================================"

# Función para limpieza agresiva de una interfaz
limpiar_interfaz_agresivo() {
    local interfaz=$1
    echo "🔧 Limpieza agresiva de interfaz $interfaz..."
    
    # 1. Mostrar estado inicial
    echo "  📊 Estado inicial:"
    ip addr show $interfaz 2>/dev/null || echo "    Interfaz no encontrada"
    
    # 2. Eliminar TODAS las conexiones que contengan el nombre de la interfaz
    echo "  🗑️ Eliminando TODAS las conexiones relacionadas..."
    nmcli -t -f NAME,DEVICE connection show 2>/dev/null | while IFS=':' read name device; do
        if [[ "$name" == *"$interfaz"* ]] || [[ "$device" == "$interfaz" ]] || [[ "$name" == *"Wired"* ]] || [[ "$name" == *"Ethernet"* ]]; then
            echo "    🗑️ Eliminando: $name"
            sudo nmcli connection delete "$name" 2>/dev/null || true
        fi
    done
    
    # 3. Forzar eliminación de conexiones automáticas
    echo "  🔄 Eliminando conexiones automáticas..."
    sudo nmcli connection show 2>/dev/null | grep -E "(ethernet|wired)" | awk '{print $1}' | while read conn; do
        echo "    🗑️ Eliminando conexión automática: $conn"
        sudo nmcli connection delete "$conn" 2>/dev/null || true
    done
    
    # 4. Parar NetworkManager temporalmente
    echo "  ⏸️ Pausando NetworkManager..."
    sudo systemctl stop NetworkManager
    sleep 2
    
    # 5. Bajar la interfaz
    echo "  ⬇️ Bajando interfaz $interfaz"
    sudo ip link set $interfaz down 2>/dev/null || true
    
    # 6. Limpiar TODAS las IPs (incluso las dinámicas)
    echo "  🧹 Limpiando TODAS las IPs de $interfaz"
    sudo ip addr flush dev $interfaz 2>/dev/null || true
    
    # 7. Limpiar rutas
    echo "  🗺️ Limpiando rutas de $interfaz"
    sudo ip route flush dev $interfaz 2>/dev/null || true
    
    # 8. Limpiar cache ARP relacionado
    echo "  🗑️ Limpiando cache ARP"
    sudo ip neigh flush dev $interfaz 2>/dev/null || true
    
    # 9. Reiniciar NetworkManager
    echo "  🔄 Reiniciando NetworkManager..."
    sudo systemctl start NetworkManager
    sleep 3
    
    # 10. Subir la interfaz limpia
    echo "  ⬆️ Subiendo interfaz $interfaz limpia"
    sudo ip link set $interfaz up 2>/dev/null || true
    sleep 2
    
    echo "  ✅ Interfaz $interfaz completamente limpiada"
}

# Detectar VM
echo "🔍 Detectando VM actual..."
HOSTNAME=$(hostname)
echo "Hostname actual: $HOSTNAME"

# Mostrar conexiones actuales
echo ""
echo "📊 Conexiones actuales ANTES de limpiar:"
nmcli connection show 2>/dev/null || echo "No hay conexiones"

# Limpiar ens34 agresivamente
echo ""
echo "🔥 Limpiando ens34 AGRESIVAMENTE..."
limpiar_interfaz_agresivo "ens34"

# Solo limpiar ens35 si estamos en vm_jhonatan
if [[ "$HOSTNAME" == *"jhonatan"* ]] && [[ "$HOSTNAME" != *"mint"* ]]; then
    echo ""
    echo "🔥 Limpiando ens35 AGRESIVAMENTE (Solo vm_jhonatan)..."
    limpiar_interfaz_agresivo "ens35"
fi

echo ""
echo "📊 Estado FINAL de las interfaces:"
ip addr show | grep -E "(ens34|ens35|inet)" || echo "Sin interfaces configuradas"

echo ""
echo "📊 Conexiones FINALES:"
nmcli connection show 2>/dev/null || echo "No hay conexiones"

echo ""
echo "✅ LIMPIEZA AGRESIVA COMPLETADA"
echo "🚀 Lista para configuración limpia con Ansible"
echo "============================================="