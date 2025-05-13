#!/bin/bash

# Получаем текущий APIKEY из .bashrc (или окружения)
APIKEY=$(grep 'APIKEY=' ~/.bashrc | cut -d'"' -f2)

if [[ -z "$APIKEY" ]]; then
  echo "❌ APIKEY не найден в ~/.bashrc"
  exit 1
fi

# Путь к systemd unit-файлу
SERVICE_FILE="/etc/systemd/system/executor.service"

# Заменим старый ключ в строках содержащих Alchemy RPC
# Найдем строку с g.alchemy.com/v2/ и заменим ключ на новый
sed -i -E "s@(g\.alchemy\.com/v2/)[a-zA-Z0-9]{28}@\1$APIKEY@g" "$SERVICE_FILE"

echo "✅ Ключ успешно обновлен в $SERVICE_FILE"

# Перезагрузка systemd, если нужно:

  systemctl daemon-reexec
  systemctl daemon-reload
  systemctl restart executor.service
  journalctl -n 100 -f -u executor | ccze -A
