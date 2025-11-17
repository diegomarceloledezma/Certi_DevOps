#!/bin/bash

# === CONFIGURACIÓN ===
ALERT_LOG="$HOME/alerts.log"
METRICS_LOG="$HOME/metrics_$(date '+%Y%m%d').log"
EMAIL="diegomarceloledezma@gmail.com"
GMAIL="diegomarceloledezma@gmail.com"
APP_PASS="mchj scou siaz xtxi"
WEBHOOK="https://discordapp.com/api/webhooks/1439835339517853809/jDI9FGKSyI8L8DvYsRDiwnKYuPIBdmRdGpufxYfwD0OCdzKPH2Z3ggSepva6p5AMFI9J"
LIMIT=80
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
HOST=$(hostname)
# =====================

# === COLORES ===
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
# ===============

# === MEDIR RECURSOS ===
# CPU (% de uso)
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d. -f1)

# RAM (% usado)
RAM_TOTAL=$(free -m | awk 'NR==2{print $2}')
RAM_USED=$(free -m | awk 'NR==2{print $3}')
RAM_PCT=$((100 * RAM_USED / RAM_TOTAL))

# Disco raíz (% usado)
DISK_PCT=$(df / | awk 'NR==2{print $5}' | tr -d '%')
# =======================

# === GUARDAR MÉTRICA ===
echo "$TIMESTAMP | CPU: ${CPU}% | RAM: ${RAM_PCT}% | DISK: ${DISK_PCT}%" >> "$METRICS_LOG"
# =========================

# === FUNCIÓN DE ALERTA ===
send_alert() {
    local metric=$1
    local value=$2
    local msg="ALERTA: $metric > ${LIMIT}% ($value%) en $HOST"

    # Mostrar en rojo
    echo -e "${RED}ALERTA: $msg${NC}"

    # Guardar en log
    echo "[$TIMESTAMP] $msg" >> "$ALERT_LOG"

    # Enviar email
    curl -s --url "smtps://smtp.gmail.com:465" \
      --ssl-reqd \
      --mail-from "$GMAIL" \
      --mail-rcpt "$EMAIL" \
      --user "$GMAIL:$APP_PASS" \
      -T <(echo -e "From: $GMAIL\nTo: $EMAIL\nSubject: ALERTA Sistema $HOST\n\n$msg") > /dev/null 2>&1

    # Enviar a Discord
    curl -H "Content-Type: application/json" -d "{\"content\": \"ALERTA: $msg\"}" "$WEBHOOK" > /dev/null 2>&1
}
# =========================

# === MOSTRAR ESTADO ===
echo "=== MONITOREO: $TIMESTAMP ==="
printf "${GREEN}CPU : ${CPU}%%${NC}  "
[ "$CPU" -gt "$LIMIT" ] && send_alert "CPU" "$CPU" || echo -e "${GREEN}OK${NC}"

printf "${GREEN}RAM : ${RAM_PCT}%%${NC}  "
[ "$RAM_PCT" -gt "$LIMIT" ] && send_alert "RAM" "$RAM_PCT" || echo -e "${GREEN}OK${NC}"

printf "${GREEN}DISK: ${DISK_PCT}%%${NC}  "
[ "$DISK_PCT" -gt "$LIMIT" ] && send_alert "DISCO" "$DISK_PCT" || echo -e "${GREEN}OK${NC}"
echo

echo "Métricas guardadas en: $METRICS_LOG"
[ -f "$ALERT_LOG" ] && echo "Alertas en: $ALERT_LOG"
# =========================
