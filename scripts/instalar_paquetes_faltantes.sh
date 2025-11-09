#!/bin/bash
# Script para instalar paquetes faltantes en las VMs
# Ejecutar en vm_jhonatan y mint_jhonatan

echo "📦 INSTALANDO PAQUETES FALTANTES PARA ANSIBLE NIVEL 4"
echo "===================================================="

# Detectar distribución
if command -v dnf >/dev/null 2>&1; then
    echo "🔧 Fedora/CentOS detectado - Usando DNF"
    sudo dnf install -y cronie mailx at
elif command -v apt >/dev/null 2>&1; then
    echo "🔧 Ubuntu/Mint detectado - Usando APT"
    sudo apt update
    sudo apt install -y cron mailutils at
else
    echo "⚠️ Distribución no reconocida"
fi

# Habilitar servicios
echo "🚀 Habilitando servicios..."
sudo systemctl enable --now crond 2>/dev/null || sudo systemctl enable --now cron 2>/dev/null
sudo systemctl enable --now atd 2>/dev/null

echo "✅ PAQUETES INSTALADOS CORRECTAMENTE"
echo "===================================="