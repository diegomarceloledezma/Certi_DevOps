#!/bin/bash

LOG_DIR="/var/log"
BACKUP_DIR="/backup/logs"
ACCIONES_LOG="/home/diego/cleanup_actions.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

sudo mkdir -p "$BACKUP_DIR"

echo "=== LIMPIEZA INICIADA: $TIMESTAMP ===" | sudo tee -a "$ACCIONES_LOG" > /dev/null
ESPACIO_ANTES=$(sudo df -h "$LOG_DIR" | awk 'NR==2 {print $4}')
echo "Espacio disponible antes: $ESPACIO_ANTES" | sudo tee -a "$ACCIONES_LOG" > /dev/null

encontrados=0
while IFS= read -r archivo; do
    ((encontrados++))
    nombre=$(basename "$archivo")
    fecha_archivo=$(date '+%Y%m%d')
    comprimido="${BACKUP_DIR}/${nombre%.log}_${fecha_archivo}.tar.gz"

    echo "Comprimiendo: $nombre" | sudo tee -a "$ACCIONES_LOG" > /dev/null

    if sudo tar -czf "$comprimido" -C "$(dirname "$archivo")" "$(basename "$archivo")" 2>/dev/null; then
        sudo rm -f "$archivo"
        echo " → Comprimido y eliminado: $comprimido" | sudo tee -a "$ACCIONES_LOG" > /dev/null
    else
        echo " → ERROR al comprimir: $nombre" | sudo tee -a "$ACCIONES_LOG" > /dev/null
    fi
done < <(find "$LOG_DIR" -type f -name "*.log" -mtime +7 2>/dev/null)

if [ "$encontrados" -eq 0 ]; then
    echo " → No se encontraron logs antiguos (>7 días)" | sudo tee -a "$ACCIONES_LOG" > /dev/null
else
    echo " → Procesados: $encontrados archivos" | sudo tee -a "$ACCIONES_LOG" > /dev/null
fi

ESPACIO_DESPUES=$(sudo df -h "$LOG_DIR" | awk 'NR==2 {print $4}')
echo "=== LIMPIEZA COMPLETADA: $(date '+%Y-%m-%d %H:%M:%S') ===" | sudo tee -a "$ACCIONES_LOG" > /dev/null
echo "Espacio disponible después: $ESPACIO_DESPUES (antes: $ESPACIO_ANTES)" | sudo tee -a "$ACCIONES_LOG" > /dev/null
echo "Archivos respaldados en: $BACKUP_DIR" | sudo tee -a "$ACCIONES_LOG" > /dev/null

echo "Limpieza completada."
echo " → Revisa el log: $ACCIONES_LOG"
echo " → Respaldos en: $BACKUP_DIR"
