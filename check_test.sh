#!/bin/bash

PROCESS_NAME="test"
MONITORING_URL="https://test.com/monitoring/test/api"
LOG_FILE="/var/log/monitoring.log"
PID_FILE="/var/run/check_process.pid"

log_message() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

ping_server() {
	local response_code

	response_code=$(curl -m 10 --connect-timeout 5 -s -o /dev/null -w "%{http_code}" "$MONITORING_URL")

	if [ "$response_code" -ne 200 ]; then
		log_message "ОШИБКА: Сервер мониторинга недоступен, код ответа: $response_code"
		return 1
	fi
	return 0
}

set -e

CURRENT_PID=$(pgrep -x "$PROCESS_NAME")

if [ -z "$CURRENT_PID" ]; then
    exit 0
fi

if [ -f "$PID_FILE" ]; then
    PREVIOUS_PID=$(cat "$PID_FILE")
else
    PREVIOUS_PID=""
fi

if [ -n "$PREVIOUS_PID" ] && [ "$CURRENT_PID" != "$PREVIOUS_PID" ]; then
    log_message "ПЕРЕЗАПУСК: Процесс $PROCESS_NAME перезапущен. Старый PID: $PREVIOUS_PID, Новый PID: $CURRENT_PID"
fi

if ! ping_server; then
    log_message "ОШИБКА: Не удалось соединиться с сервером мониторинга"
fi

echo "$CURRENT_PID" > "$PID_FILE"
