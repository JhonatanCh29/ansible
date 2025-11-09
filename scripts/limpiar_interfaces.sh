#!/bin/bash
# Script para LIMPIAR COMPLETAMENTE las interfaces ens34 en todas las VMs
# Ejecutar este script EN CADA VM antes de configurar las IPs

echo "🧹 LIMPIEZA COMPLETA DE INTERFACES DE RED"
echo "========================================="

# Función para limpiar una interfaz
limpiar_interfaz() {
    local interfaz=$1
    echo "🔧 Limpiando interfaz $interfaz..."
    
    # 1. Bajar la interfaz
    echo "  - Bajando interfaz $interfaz"
    sudo ip link set $interfaz down 2>/dev/null || true
    
    # 2. Limpiar todas las IPs asignadas
    echo "  - Limpiando IPs de $interfaz"
    sudo ip addr flush dev $interfaz 2>/dev/null || true
    
    # 3. Eliminar todas las conexiones de NetworkManager
    echo "  - Eliminando conexiones NetworkManager de $interfaz"
    nmcli connection show 2>/dev/null | grep $interfaz | awk '{print $1}' | while read conn; do
        if [ -n "$conn" ]; then
            echo "    Eliminando conexión: $conn"
            sudo nmcli connection delete "$conn" 2>/dev/null || true
        fi
    done
    
    # 4. Eliminar rutas específicas de esta interfaz
    echo "  - Limpiando rutas de $interfaz"
    sudo ip route flush dev $interfaz 2>/dev/null || true
    
    # 5. Subir la interfaz limpia
    echo "  - Subiendo interfaz $interfaz limpia"
    sudo ip link set $interfaz up 2>/dev/null || true
    
    echo "  ✅ Interfaz $interfaz limpiada"
}

# Detectar si estamos en VM específica basado en hostname o preguntarle al usuario
echo "🔍 Detectando VM actual..."
HOSTNAME=$(hostname)
echo "Hostname actual: $HOSTNAME"

# Limpiar ens34 en todas las VMs
echo ""
echo "🧹 Limpiando ens34 (LAN del laboratorio)..."
limpiar_interfaz "ens34"

# Solo limpiar ens35 si estamos en vm_jhonatan (el router)
if [[ "$HOSTNAME" == *"jhonatan"* ]] && [[ "$HOSTNAME" != *"mint"* ]]; then
    echo ""
    echo "🧹 Limpiando ens35 (WAN) - Solo en vm_jhonatan..."
    limpiar_interfaz "ens35"
fi

echo ""
echo "🔍 Estado actual de las interfaces:"
ip addr show | grep -E "(ens34|ens35|inet)"

echo ""
echo "✅ LIMPIEZA COMPLETA TERMINADA"
echo "Ahora puedes configurar las IPs con Ansible o manualmente"
echo "========================================================"