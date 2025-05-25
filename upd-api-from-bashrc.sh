#!/bin/bash

read -p "🔐 Введите новый APIKEY: " NEW_APIKEY

if [[ -z "$NEW_APIKEY" ]]; then
  echo "❌ APIKEY пустой"
  exit 1
fi

SERVICE_FILE="/etc/systemd/system/executor.service"
BASHRC="$HOME/.bashrc"

# 📝 Обновим или добавим переменную APIKEY в .bashrc
if grep -q "^export APIKEY=" "$BASHRC"; then
  sed -i "s/^export APIKEY=.*/export APIKEY=$NEW_APIKEY/" "$BASHRC"
else
  echo "export APIKEY=$NEW_APIKEY" >> "$BASHRC"
fi

# 🛠 Загрузим обновлённый .bashrc
source "$BASHRC"

# 🔧 Обновим APIKEY в unit-файле (если используется в RPC URL)
sed -i -E "s@(g\.alchemy\.com/v2/)[^\\\" ]+@\1$NEW_APIKEY@g" "$SERVICE_FILE"

echo "✅ Ключ обновлён в .bashrc и $SERVICE_FILE"

# 🔄 Перезапустим сервис
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart executor.service
systemctl restart any-arb.service

# 📋 Покажем логи
journalctl -u any-arb.service -f | ccze -A
