#!/bin/bash

echo "Welcome to the t3rn Executor Updater by snoopfear!"

SERVICE_FILE="/etc/systemd/system/executor.service"

# Шаг 0: Остановка сервиса executor
echo "Stopping the executor service..."
sudo systemctl stop executor
if [ $? -ne 0 ]; then
    echo "Warning: Failed to stop the executor service. It might not be running."
fi

# Шаг 1: Добавление строк в файл сервиса
echo "Updating the service file with additional RPC endpoints..."
sudo sed -i.bak '/Restart=always/i Environment=RPC_ENDPOINTS_ARBT=https://arb-sepolia.g.alchemy.com/v2/cJOnOR6cLxWQj6q9aH3WXeOjFCXlFBwn\nEnvironment=RPC_ENDPOINTS_OPSP=https://opt-sepolia.g.alchemy.com/v2/cJOnOR6cLxWQj6q9aH3WXeOjFCXlFBwn\nEnvironment=RPC_ENDPOINTS_BSSP=https://base-sepolia.g.alchemy.com/v2/cJOnOR6cLxWQj6q9aH3WXeOjFCXlFBwn\nEnvironment=RPC_ENDPOINTS_BLSS=https://blast-sepolia.g.alchemy.com/v2/cJOnOR6cLxWQj6q9aH3WXeOjFCXlFBwn' "$SERVICE_FILE"

if [ $? -ne 0 ]; then
    echo "Error: Failed to update the service file. Please check the file path and permissions."
    exit 1
fi

echo "Service file updated successfully!"

# Шаг 2: Удаление старого архива
echo "Removing old archive if exists..."
rm -rf executor-linux-v*.tar.gz

# Шаг 3: Удаление старой папки с executor'ом
echo "Removing old executor directory if exists..."
rm -rf ~/executor

# Шаг 4: Обновление и улучшение пакетов
echo "Updating and upgrading system packages..."
sudo apt update && sudo apt -qy upgrade

# Шаг 5: Указание ссылки для загрузки и имени файла
EXECUTOR_URL="https://github.com/t3rn/executor-release/releases/download/v0.40.0/executor-linux-v0.40.0.tar.gz"
EXECUTOR_FILE="executor-linux-v0.40.0.tar.gz"

echo "Downloading the Executor binary from $EXECUTOR_URL..."
curl -L -o $EXECUTOR_FILE $EXECUTOR_URL

# Проверка успешности загрузки
if [ $? -ne 0 ]; then
    echo "Error: Failed to download the Executor binary. Please check your internet connection and try again."
    exit 1
fi

# Шаг 6: Распаковка бинарного файла
echo "Extracting the binary..."
tar -xzvf $EXECUTOR_FILE
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract the binary. Please check the archive and try again."
    exit 1
fi

# Шаг 7: Удаление архива после распаковки
echo "Cleaning up: removing downloaded archive..."
rm -rf $EXECUTOR_FILE

# Шаг 8: Перезапуск systemd и активация сервиса
echo "Reloading systemd daemon and restarting the executor service..."
sudo systemctl daemon-reload
sudo systemctl enable executor
sudo systemctl restart executor

if [ $? -ne 0 ]; then
    echo "Error: Failed to restart the executor service. Please check the service configuration."
    exit 1
fi

# Шаг 9: Просмотр логов сервиса
echo "Showing the last 100 lines of logs for the executor service..."
journalctl -n 100 -f -u executor | ccze -A
