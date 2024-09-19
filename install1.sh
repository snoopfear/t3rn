#!/bin/bash

echo "Welcome to the t3rn Executor Setup by snoopfear!"

# Установка ccze для цветного форматирования логов
echo "Installing ccze for colored log formatting..."
sudo apt -q update
sudo apt -qy install ccze

# Проверка на существование переменной PRIVATE_KEY_LOCAL
if [ -z "$PRIVATE_KEY_LOCAL" ]; then
    # Запрос ввода приватного ключа
    read -p "Enter your Private Key from Metamask: " PRIVATE_KEY_LOCAL
fi

# Переход в домашнюю директорию
cd $HOME

# Удаление старой папки с executor'ом
rm -rf ~/executor

# Обновление и улучшение пакетов
sudo apt -qy upgrade

# Указание ссылки для загрузки и имени файла
EXECUTOR_URL="https://github.com/t3rn/executor-release/releases/download/v0.21.0/executor-linux-v0.21.0.tar.gz"
EXECUTOR_FILE="executor-linux-v0.21.0.tar.gz"

echo "Downloading the Executor binary from $EXECUTOR_URL..."
curl -L -o $EXECUTOR_FILE $EXECUTOR_URL

# Проверка успешности загрузки
if [ $? -ne 0 ]; then
    echo "Failed to download the Executor binary. Please check your internet connection and try again."
    exit 1
fi

echo "Extracting the binary..."
tar -xzvf $EXECUTOR_FILE

# Удаление архива после распаковки
rm -rf $EXECUTOR_FILE

# Создание скрипта restart_executor.sh
sudo tee /usr/local/bin/restart_executor.sh > /dev/null <<EOF
#!/bin/bash
systemctl restart executor.service
echo "Cron job executed at \$(date)" >> /tmp/cron_test.log
EOF

# Сделать скрипт исполняемым
sudo chmod +x /usr/local/bin/restart_executor.sh

# Добавление cron-задания для выполнения каждые 15 минут
(crontab -l 2>/dev/null; echo "*/15 * * * * sh /usr/local/bin/restart_executor.sh") | crontab -

echo "Cron job to restart the executor every 15 minutes has been created."

# Создание systemd сервиса для t3rn Executor
sudo tee /etc/systemd/system/executor.service > /dev/null <<EOF
[Unit]
Description=t3rn Executor Service
After=network.target

[Service]
ExecStart=/root/executor/executor/bin/executor  # Полный путь к бинарному файлу
Environment="NODE_ENV=testnet"
Environment="LOG_LEVEL=debug"
Environment="LOG_PRETTY=false"
Environment="PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL"
Environment="ENABLED_NETWORKS=arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,l1rn"
Environment="EXECUTOR_ARBITRUM_SEPOLIA_RPC_URLS=https://arb-sepolia.g.alchemy.com/v2/lNTUkf8We6CAI3gpMaBGyPsSz7bRk2U1"
Environment="EXECUTOR_OPTIMISM_SEPOLIA_RPC_URLS=https://opt-sepolia.g.alchemy.com/v2/lNTUkf8We6CAI3gpMaBGyPsSz7bRk2U1"
Environment="EXECUTOR_BASE_SEPOLIA_RPC_URLS=https://base-sepolia.g.alchemy.com/v2/lNTUkf8We6CAI3gpMaBGyPsSz7bRk2U1"
Environment="EXECUTOR_BLAST_SEPOLIA_RPC_URLS=https://blast-sepolia.g.alchemy.com/v2/lNTUkf8We6CAI3gpMaBGyPsSz7bRk2U1"

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
echo "Displaying the last 100 lines of the 'executor' service log and following updates with ccze formatting..."
journalctl -n 100 -f -u executor | ccze -A
