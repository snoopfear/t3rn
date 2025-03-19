#!/bin/bash

set -e  # Выход при ошибках

echo "Welcome to the t3rn Executor Updater by snoopfear!"

SERVICE_FILE="/etc/systemd/system/executor.service"

# Шаг 0: Остановка сервиса executor
echo "Stopping the executor service..."
sudo systemctl stop executor || echo "Warning: Failed to stop the executor service. It might not be running."

# Шаг 1: Удаление старого архива и папки с executor'ом
echo "Removing old archive and executor directory..."
rm -rf executor-linux-v*.tar.gz ~/executor

# Шаг 2: Обновление и улучшение пакетов
echo "Updating and upgrading system packages..."
sudo apt update && sudo apt -qy upgrade

# Шаг 3: Получение URL последнего релиза
LATEST_RELEASE_URL=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep "browser_download_url" | grep "executor-linux" | cut -d '"' -f 4)
if [[ -z "$LATEST_RELEASE_URL" ]]; then
    echo "Error: Failed to fetch the latest release URL. Check the repository or your internet connection."
    exit 1
fi

EXECUTOR_FILE=$(basename "$LATEST_RELEASE_URL")

# Шаг 4: Загрузка последнего релиза
echo "Downloading the latest Executor binary from $LATEST_RELEASE_URL..."
curl -L -o "$EXECUTOR_FILE" "$LATEST_RELEASE_URL"

# Шаг 5: Распаковка бинарного файла
echo "Extracting the binary..."
tar -xzvf "$EXECUTOR_FILE"

# Шаг 6: Удаление архива после распаковки
echo "Cleaning up: removing downloaded archive..."
rm -rf "$EXECUTOR_FILE"

# Шаг 7: Перезапуск systemd и активация сервиса
echo "Reloading systemd daemon and restarting the executor service..."
sudo systemctl daemon-reload
sudo systemctl enable executor
sudo systemctl restart executor || { echo "Error: Failed to restart the executor service. Check service logs."; exit 1; }

# Шаг 8: Просмотр логов сервиса
echo "Showing the last 100 lines of logs for the executor service..."
journalctl -n 100 -f -u executor | ccze -A
