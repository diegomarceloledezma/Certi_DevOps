#!/bin/bash

REPO="https://github.com/rayner-villalba-coderoad-com/clash-of-clan"
DIR="/var/www/clash-of-clan"
LOG="$HOME/deploy.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
WEBHOOK="https://discordapp.com/api/webhooks/1439835339517853809/jDI9FGKSyI8L8DvYsRDiwnKYuPIBdmRdGpufxYfwD0OCdzKPH2Z3ggSepva6p5AMFI9J"

echo "[$TIMESTAMP] Iniciando despliegue..." >> "$LOG"

mkdir -p "$DIR"

if [ ! -d "$DIR/.git" ]; then
    echo "[$TIMESTAMP] Clonando repositorio..." >> "$LOG"
    if git clone "$REPO" "$DIR" >> "$LOG" 2>&1; then
        echo "[$TIMESTAMP] Repositorio clonado" >> "$LOG"
    else
        echo "[$TIMESTAMP] ERROR: Falló git clone" >> "$LOG"
        curl -H "Content-Type: application/json" -d "{\"content\": \"ERROR: Falló git clone en $(hostname)\"}" "$WEBHOOK"
        exit 1
    fi
else
    echo "[$TIMESTAMP] Actualizando repositorio..." >> "$LOG"
    cd "$DIR" || exit 1
    if git pull >> "$LOG" 2>&1; then
        echo "[$TIMESTAMP] Repositorio actualizado" >> "$LOG"
    else
        echo "[$TIMESTAMP] ERROR: Falló git pull" >> "$LOG"
        curl -H "Content-Type: application/json" -d "{\"content\": \"ERROR: Falló git pull en $(hostname)\"}" "$WEBHOOK"
        exit 1
    fi
fi

echo "[$TIMESTAMP] Reiniciando nginx..." >> "$LOG"
if sudo systemctl restart nginx >> "$LOG" 2>&1; then
    echo "[$TIMESTAMP] nginx reiniciado OK" >> "$LOG"
    curl -H "Content-Type: application/json" -d "{\"content\": \"DEPLOY OK: Clash of Clan actualizado en $(hostname)\"}" "$WEBHOOK"
else
    echo "[$TIMESTAMP] ERROR: Falló restart nginx" >> "$LOG"
    curl -H "Content-Type: application/json" -d "{\"content\": \"ERROR: nginx no reinició en $(hostname)\"}" "$WEBHOOK"
    exit 1
fi

echo "[$TIMESTAMP] Despliegue COMPLETADO" >> "$LOG"
echo "Despliegue completado. Revisa: $LOG"
                                            