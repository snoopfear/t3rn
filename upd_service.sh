#!/bin/bash

read -p "Enter your API Key: " APIKEY

# Обновляем ~/.bashrc
sed -i '/APIKEY=/d' ~/.bashrc
echo "export APIKEY=\"$APIKEY\"" >> ~/.bashrc

# Останавливаем и удаляем старый сервис
sudo systemctl stop executor
sudo systemctl disable executor
sudo rm -f /etc/systemd/system/executor.service

# Создаём systemd unit
cat <<EOF | sudo tee /etc/systemd/system/executor.service >/dev/null
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
Environment="NETWORKS_DISABLED=blast-sepolia,monad-testnet,arbitrum,base,optimism"
Environment="ENABLED_NETWORKS=arbitrum-sepolia,optimism-sepolia,l1rn,base-sepolia,unichain-sepolia"
Environment="RPC_ENDPOINTS={\
    \\\"l2rn\\\": [\\\"https://t3rn-b2n.blockpi.network/v1/rpc/public\\\", \\\"https://b2n.rpc.caldera.xyz/http\\\"],\
    \\\"arbt\\\": [\\\"https://arb-sepolia.g.alchemy.com/v2/$APIKEY\\\"],\
    \\\"bast\\\": [\\\"https://base-sepolia.g.alchemy.com/v2/$APIKEY\\\"],\
    \\\"opst\\\": [\\\"https://opt-sepolia.g.alchemy.com/v2/$APIKEY\\\"],\
    \\\"unit\\\": [\\\"https://unichain-sepolia.g.alchemy.com/v2/$APIKEY\\\"]\
}"
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Перезапуск systemd и запуск сервиса
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable executor
sudo systemctl restart executor

# Лог с цветами
journalctl -n 100 -f -u executor | ccze -A
