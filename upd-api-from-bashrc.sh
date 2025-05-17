#!/bin/bash

read -p "🔐 Введите новый APIKEY: " NEW_APIKEY

if [[ -z "$NEW_APIKEY" ]]; then
  echo "❌ APIKEY пустой"
  exit 1
fi

SERVICE_FILE="/etc/systemd/system/executor.service"

source ~/.bashrc

# Замена ключа до символа \
sed -i -E "s@(g\.alchemy\.com/v2/)[^\\]+@\\1$NEW_APIKEY@g" "$SERVICE_FILE"

echo "✅ Ключ успешно обновлён в $SERVICE_FILE"

systemctl daemon-reexec
systemctl daemon-reload
systemctl restart executor.service

journalctl -n 100 -f -u executor | ccze -A
