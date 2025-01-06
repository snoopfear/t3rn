#!/bin/bash

echo "Welcome to the t3rn Executor Updater by snoopfear!"

SERVICE_FILE="/etc/systemd/system/executor.service"

# Шаг 0: Остановка сервиса executor
echo "Stopping the executor service..."
sudo systemctl stop executor
if [ $? -ne 0 ]; then
    echo "Warning: Failed to stop the executor service. It might not be running."
fi

# Шаг 1: Обновление содержимого executor.service, сохраняя PRIVATE_KEY_LOCAL
echo "Updating the systemd service file: $SERVICE_FILE..."

# Сохранение строки с PRIVATE_KEY_LOCAL, если она существует
PRIVATE_KEY_LINE=$(grep "PRIVATE_KEY_LOCAL" "$SERVICE_FILE" 2>/dev/null)

if [ -z "$PRIVATE_KEY_LINE" ]; then
    echo "Warning: PRIVATE_KEY_LOCAL variable not found in the existing service file. Using default value."
    PRIVATE_KEY_LINE="Environment=PRIVATE_KEY_LOCAL=your_default_private_key_here"
fi

# Перезапись файла
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=t3rn Executor Service
After=network.target

[Service]
ExecStart=/root/executor/executor/bin/executor  # Полный путь к бинарному файлу
Environment=NODE_ENV=testnet
Environment=LOG_LEVEL=debug
Environment=LOG_PRETTY=false
$PRIVATE_KEY_LINE
Environment=ENABLED_NETWORKS=arbitrum-sepolia,optimism-sepolia,l1rn,base-sepolia,blast-sepolia
Environment=EXECUTOR_PROCESS_ORDERS=true
Environment=EXECUTOR_PROCESS_CLAIMS=true
Environment=EXECUTOR_MAX_L3_GAS_PRICE=1000
Environment=EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=true
Environment=RPC_ENDPOINTS_L1RN=https://brn.rpc.caldera.xyz/
#Environment="RPC_ENDPOINTS_ARBT=https://rpc.ankr.com/arbitrum_sepolia/..."
#Environment="RPC_ENDPOINTS_OPSP=https://rpc.ankr.com/optimism_sepolia/..."
#Environment="RPC_ENDPOINTS_BSSP=https://rpc.ankr.com/base_sepolia/..."
#Environment="RPC_ENDPOINTS_BLSS=https://rpc.ankr.com/blast_testnet_sepolia/..."

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOL

if [ $? -ne 0 ]; then
    echo "Error: Failed to create or update the service file. Please check permissions."
    exit 1
fi

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
EXECUTOR_URL="https://github.com/t3rn/executor-release/releases/download/v0.33.0/executor-linux-v0.33.0.tar.gz"
EXECUTOR_FILE="executor-linux-v0.33.0.tar.gz"

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
