#!/bin/bash

if [ -z "$1" ]; then
  echo "Uso: $0 <servicio>"
  exit 1
fi

SERVICIO=$1
EMAIL="diegomarceloledezma@gmail.com"
GMAIL_USER="diegomarceloledezma@gmail.com"
GMAIL_APP_PASS="mchj scou siaz xtxi"
HOST=$(hostname)
FECHA=$(date "+%Y-%m-%d %H:%M:%S")

STATUS=$(systemctl is-active $SERVICIO 2>/dev/null || echo "desconocido")

if [ "$STATUS" = "active" ]; then
  echo "$FECHA - $SERVICIO está activo"
  echo "$FECHA - $SERVICIO : ACTIVE" >> service_status.log
  ESTADO_EMAIL="Activo"
else
  echo "$FECHA - ALERTA: $SERVICIO NO está activo!"
  echo "$FECHA - $SERVICIO : INACTIVE" >> service_status.log
  ESTADO_EMAIL="Inactivo - ALERTA"
fi

MENSAJE="Servicio: $SERVICIO\nEstado: $STATUS\nHost: $HOST (VirtualBox)\nFecha: $FECHA"

#esta parte es para enviar al correo la notificacion
curl -s --url "smtps://smtp.gmail.com:465" \
  --ssl-reqd \
  --mail-from "$GMAIL_USER" \
  --mail-rcpt "$EMAIL" \
  --user "$GMAIL_USER:$GMAIL_APP_PASS" \
  -T <(echo -e "From: $GMAIL_USER\nTo: $EMAIL\nSubject: Estado del servicio $SERVICIO ($ESTADO_EMAIL)\n\n$MENSAJE") \
  > /dev/null 2>&1

echo "$FECHA - Email enviado a $EMAIL"