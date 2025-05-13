#!/bin/bash

# Запрос нового APIKEY у пользователя
read -p "🔐 Введите новый APIKEY (28 символов): " NEW_APIKEY

# Обновляем или добавляем APIKEY в ~/.bashrc
if grep -q 'APIKEY=' ~/.bashrc; then
  sed -i -E "s@export APIKEY=\"[^\"]*\"@export APIKEY=\"$NEW_APIKEY\"@" ~/.bashrc
else
  echo "export APIKEY=\"$NEW_APIKEY\"" >> ~/.bashrc
fi

# Подгружаем переменную в текущую сессию
export APIKEY="$NEW_APIKEY"

echo "✅ APIKEY успешно обновлён в ~/.bashrc"

# Путь к systemd unit-файлу
SERVICE_FILE="/etc/systemd/system/executor.service"

# Проверка наличия файла
if [[ ! -f "$SERVICE_FILE" ]]; then
  echo "❌ Файл systemd unit не найден: $SERVICE_FILE"
  exit 1
fi

# Заменим ключ в URL Alchemy внутри systemd unit
sed -i -E "s@(g\.alchemy\.com/v2/)[a-zA-Z0-9]{28}@\1$APIKEY@g" "$SERVICE_FILE"

echo "✅ Ключ успешно обновлён в $SERVICE_FILE"

# Перезапуск systemd
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart executor.service

echo "🔁 executor.service перезапущен. Последние логи:"
journalctl -n 100 -f -u executor | ccze -A
