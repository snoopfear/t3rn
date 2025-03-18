#!/bin/bash

echo "Welcome to the t3rn Executor Setup by snoopfear!"

# Установка ccze для цветного форматирования логов
echo "Installing ccze for colored log formatting..."
sudo apt -q update
sudo apt -qy install ccze

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

# Скачать последнюю версию Executor
LATEST_VERSION=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
wget https://github.com/t3rn/executor-release/releases/download/$LATEST_VERSION/executor-linux-$LATEST_VERSION.tar.gz

# Распаковка архива
mkdir -p ~/executor
tar -xzf executor-linux-*.tar.gz -C ~/executor
rm -rf executor-linux-*.tar.gz

# Создание systemd сервиса для t3rn Executor
sudo tee /etc/systemd/system/executor.service > /dev/null <<EOF
[Unit]
Description=t3rn Executor Service
After=network.target

[Service]
ExecStart=$HOME/executor/bin/executor
Environment="ENVIRONMENT=testnet"
Environment="LOG_LEVEL=debug"
Environment="LOG_PRETTY=false"
Environment="PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL"
Environment="EXECUTOR_PROCESS_BIDS_ENABLED=true"
Environment="EXECUTOR_PROCESS_ORDERS_ENABLED=true"
Environment="EXECUTOR_PROCESS_CLAIMS_ENABLED=true"
Environment="EXECUTOR_MAX_L3_GAS_PRICE=1000"
Environment="ENABLED_NETWORKS=arbitrum-sepolia,optimism-sepolia,l1rn,base-sepolia,unichain-sepolia"
Environment="RPC_ENDPOINTS={\
    \"l2rn\": [\"https://b2n.rpc.caldera.xyz/http\"],\
    \"arbt\": [\"https://arbitrum-sepolia.drpc.org\", \"https://sepolia-rollup.arbitrum.io/rpc\", \"https://arb-sepolia.g.alchemy.com/v2/lNTUkf8We6CAI3gpMaBGyPsSz7bRk2U1\"],\
    \"bast\": [\"https://base-sepolia-rpc.publicnode.com\", \"https://base-sepolia.drpc.org\", \"https://base-sepolia.g.alchemy.com/v2/lNTUkf8We6CAI3gpMaBGyPsSz7bRk2U1\"],\
    \"opst\": [\"https://sepolia.optimism.io\", \"https://optimism-sepolia.drpc.org\", \"https://opt-sepolia.g.alchemy.com/v2/lNTUkf8We6CAI3gpMaBGyPsSz7bRk2U1\"],\
    \"unit\": [\"https://unichain-sepolia.drpc.org\", \"https://sepolia.unichain.org\", \"https://unichain-sepolia.g.alchemy.com/v2/lNTUkf8We6CAI3gpMaBGyPsSz7bRk2U1\"]\
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
