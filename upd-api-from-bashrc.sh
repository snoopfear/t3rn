#!/bin/bash

read -p "🔐 Введите новый APIKEY: " NEW_APIKEY

if [[ -z "$NEW_APIKEY" ]]; then
  echo "❌ APIKEY пустой"
  exit 1
fi

SERVICE_FILE="/etc/systemd/system/executor.service"
ANY_ARB_FILE="/etc/systemd/system/any-arb.service"
BASHRC="$HOME/.bashrc"

# 📝 Обновим или добавим переменную APIKEY в .bashrc
if grep -q "^export APIKEY=" "$BASHRC"; then
  sed -i "s/^export APIKEY=.*/export APIKEY=$NEW_APIKEY/" "$BASHRC"
else
  echo "export APIKEY=$NEW_APIKEY" >> "$BASHRC"
fi

# 🛠 Загрузим обновлённый .bashrc
source "$BASHRC"

# 🔧 Обновим APIKEY в executor.service (например, в RPC URL)
sed -i -E "s@(g\.alchemy\.com/v2/)[^\\\" ]+@\1$NEW_APIKEY@g" "$SERVICE_FILE"

# 🔧 Обновим переменную APIKEY в any-arb.service
if grep -q "^Environment=APIKEY=" "$ANY_ARB_FILE"; then
  sed -i "s|^Environment=APIKEY=.*|Environment=APIKEY=$NEW_APIKEY|" "$ANY_ARB_FILE"
else
  # Вставим переменную под секцией [Service], если её не было
  sed -i "/^\[Service\]/a Environment=APIKEY=$NEW_APIKEY" "$ANY_ARB_FILE"
fi

echo "✅ Ключ обновлён в .bashrc, $SERVICE_FILE и $ANY_ARB_FILE"

# 🔄 Перезапустим сервисы
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart executor.service
systemctl restart any-arb.service

# 📋 Покажем логи
journalctl -u any-arb.service -f | ccze -A
