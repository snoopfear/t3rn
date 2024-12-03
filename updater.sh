#!/bin/bash

echo "Welcome to the t3rn Executor Updater by snoopfear!"

# Переход в домашнюю директорию
cd $HOME
rm -rf updater.sh
sudo systemctl stop executor

# Удаление архива после распаковки
rm -rf $EXECUTOR_FILE

# Удаление старой папки с executor'ом
rm -rf ~/executor

# Обновление и улучшение пакетов
sudo apt -qy upgrade

# Указание ссылки для загрузки и имени файла
EXECUTOR_URL="https://github.com/t3rn/executor-release/releases/download/v0.26.0/executor-linux-v0.26.0.tar.gz"
EXECUTOR_FILE="executor-linux-v0.26.0.tar.gz"

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

sudo systemctl restart executor
journalctl -n 100 -f -u executor | ccze -A
