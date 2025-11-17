
```markdown
```

### Nivel 1: Fundamentos del scripting en Bash
**Script:** `check_service.sh <nombre_servicio>`

**Funcionalidad:**
- Verifica el estado del servicio con `systemctl is-active`
- Muestra mensaje en pantalla con timestamp
- Guarda resultado (ACTIVE/INACTIVE) en `service_status.log`
- Envía email al celular usando `curl` + Gmail SMTP

**Ejemplo de uso:**
```bash
./check_service.sh apache2
./check_service.sh nginx
```

**Bonus logrados:**
- Timestamp en logs y pantalla
- Notificación por email al celular

### Nivel 2: Automatización de tareas de mantenimiento
**Script:** `cleanup_logs.sh`

**Funcionalidad:**
- Busca archivos `.log` mayores a 7 días en `/var/log`
- Los comprime en `.tar.gz` con fecha en el nombre
- Los mueve a `/backup/logs/`
- Elimina originales solo si la compresión fue exitosa
- Genera log detallado con espacio antes/después y contador

**Ejemplo de uso:**
```bash
sudo ./cleanup_logs.sh
cat ~/cleanup_actions.log
ls /backup/logs/
```

**Bonus logrados:**
- Programado con `cron` cada noche a las 2:00 AM
- Muestra espacio liberado antes y después

### Nivel 3: Despliegue automatizado (mini-CI/CD)
**Script:** `deploy_app.sh`

**Funcionalidad:**
- Clona o actualiza el repositorio:  
  `https://github.com/rayner-villalba-coderoad-com/clash-of-clan`
- Copia automáticamente los archivos a `/var/www/html/`
- Reinicia el servidor web (apache2 o nginx)
- Guarda todo el proceso en `deploy.log`
- Envía notificaciones a Discord (éxito o fallo)

**Ejemplo de uso:**
```bash
./deploy_app.sh
```
Luego abre en el navegador: **http://localhost** → debe aparecer **UPB Clash of Clans** con las cartas de tropas.

**Bonus logrados:**
- Webhook de Discord (notificaciones en tiempo real)
- Control completo de errores (git, copia, reinicio)
- Copia automática al sitio web

### Nivel 4: Monitoreo y Alertas
**Script:** `monitor_system.sh`

**Funcionalidad:**
- Mide uso de CPU, RAM y disco raíz
- Alerta si cualquiera supera el 80%
- Colores en terminal: verde = OK, rojo = ALERTA
- Guarda histórico diario: `metrics_20251117.log`
- Envía alertas por email + Discord

**Ejemplo de uso:**
```bash
./monitor_system.sh                  
stress --cpu 8 --timeout 20 & ./monitor_system.sh   # Simular alta carga
```

**Bonus logrados:**
- Colores en la salida
- Histórico diario de métricas
- Alertas dobles (email + Discord)
- Programado con `cron` cada 5 minutos

### Tareas programadas (cron)
```bash
# Limpieza nocturna
0 2 * * * /home/diego/cleanup_logs.sh >> /home/diego/cleanup_cron.log 2>&1

# Monitoreo cada 5 minutos
*/5 * * * * /home/diego/monitor_system.sh >> /home/diego/monitor_cron.log 2>&1
```