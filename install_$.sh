#!/bin/bash

echo "Welcome to the t3rn Executor Setup by snoopfear!"

# Установка ccze для цветного форматирования логов
echo "Installing ccze for colored log formatting..."
sudo apt -q update
sudo apt -qy install ccze

# Запрос API Key
read -p "Enter your API Key: " APIKEY
export APIKEY
echo "export APIKEY=\"$APIKEY\"" >> ~/.bashrc

# Проверка на существование переменной PRIVATE_KEY_LOCAL
if [ -z "${PRIVATE_KEY_LOCAL}" ]; then
    # Запрос ввода приватного ключа
    read -p "Enter your Private Key from Metamask: " PRIVATE_KEY_LOCAL
    # Экспорт переменной
    export PRIVATE_KEY_LOCAL
    
    # Сохранение переменной в .bashrc для постоянного использования
    echo "export PRIVATE_KEY_LOCAL=\"$PRIVATE_KEY_LOCAL\"" >> ~/.bashrc
else
    echo "Using existing PRIVATE_KEY_LOCAL: $PRIVATE_KEY_LOCAL"
fi

# Переход в домашнюю директорию
cd $HOME

# Удаление старой папки с executor'ом
rm -rf ~/executor

# Обновление и улучшение пакетов
sudo apt -qy upgrade

# Получаем последнюю версию
LATEST_VERSION="v0.53.1"
EXECUTOR_FILE="executor-linux-$LATEST_VERSION.tar.gz"
EXECUTOR_URL="https://github.com/t3rn/executor-release/releases/download/$LATEST_VERSION/$EXECUTOR_FILE"

echo "Downloading Executor from $EXECUTOR_URL..."
curl -L -o "$EXECUTOR_FILE" "$EXECUTOR_URL"

# Проверяем успешность загрузки
if [ ! -f "$EXECUTOR_FILE" ]; then
    echo "Error: Failed to download $EXECUTOR_FILE. Exiting..."
    exit 1
fi

# Шаг 5: Распаковка бинарного файла
echo "Extracting the binary..."
tar -xzvf "$EXECUTOR_FILE"

# Шаг 6: Удаление архива после распаковки
echo "Cleaning up: removing downloaded archive..."
rm -rf "$EXECUTOR_FILE"

# Создание systemd сервиса для t3rn Executor
sudo tee /etc/systemd/system/executor.service > /dev/null <<EOF
[Unit]
Description=t3rn Executor Service
After=network.target

[Service]
ExecStart=$HOME/executor/executor/bin/executor
Environment="ENVIRONMENT=testnet"
Environment="LOG_LEVEL=debug"
Environment="LOG_PRETTY=false"
Environment="PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL"
Environment="EXECUTOR_PROCESS_BIDS_ENABLED=true"
Environment="EXECUTOR_PROCESS_ORDERS_ENABLED=true"
Environment="EXECUTOR_PROCESS_CLAIMS_ENABLED=true"
Environment="EXECUTOR_MAX_L3_GAS_PRICE=10000"
Environment="EXECUTOR_ENABLE_BATCH_BIDING=true"
Environment="EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false"
Environment="EXECUTOR_PROCESS_ORDERS_API_ENABLED=false"
Environment="EXECUTOR_PROCESS_BIDS_API_ENABLED=false"
Environment="EXECUTOR_PROCESS_CLAIMS_API_ENABLED=false"
Environment="ENABLED_NETWORKS=arbitrum-sepolia,optimism-sepolia,l1rn,base-sepolia,unichain-sepolia"
Environment="RPC_ENDPOINTS={\
    \"l2rn\": [\"https://b2n.rpc.caldera.xyz/http\"],\
    \"arbt\": [\"https://arbitrum-sepolia.drpc.org\", \"https://sepolia-rollup.arbitrum.io/rpc\", \"https://arb-sepolia.g.alchemy.com/v2/$APIKEY\"],\
    \"bast\": [\"https://base-sepolia-rpc.publicnode.com\", \"https://base-sepolia.drpc.org\", \"https://base-sepolia.g.alchemy.com/v2/$APIKEY\"],\
    \"opst\": [\"https://sepolia.optimism.io\", \"https://optimism-sepolia.drpc.org\", \"https://opt-sepolia.g.alchemy.com/v2/$APIKEY\"],\
    \"unit\": [\"https://unichain-sepolia.drpc.org\", \"https://sepolia.unichain.org\", \"https://unichain-sepolia.g.alchemy.com/v2/$APIKEY\"]\
}"
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Перезагрузка systemd для применения изменений
sudo systemctl daemon-reload

# Включение и запуск сервиса
sudo systemctl enable executor.service
sudo systemctl start executor.service

# Показ последних 100 строк журнала и непрерывное обновление с ccze
echo "journalctl -n 100 -f -u executor | ccze -A"
