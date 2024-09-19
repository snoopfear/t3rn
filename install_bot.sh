#!/bin/bash

echo "Welcome to the t3rn Bot Setup by snoopfear!"

# Установка необходимых пакетов
echo "Updating package list and installing necessary packages..."
sudo apt -q update
sudo apt -qy install git curl

# Запрос ввода приватного ключа
read -p "Enter your Private Key from Metamask: " PRIVATE_KEY_LOCAL

# Установка Node.js и npm
echo "Installing Node.js (v14 or later) and npm (v6 or later)..."
curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt -qy install nodejs

# Проверка установки Node.js и npm
echo "Checking Node.js and npm versions..."
node -v
npm -v

# Клонирование репозитория
echo "Cloning the repository..."
git clone https://github.com/snoopfear/t3rn-airdrop-bot.git
cd t3rn-airdrop-bot || exit

# Установка зависимостей
echo "Installing dependencies..."
npm install

# Создание файла privateKeys.json
echo "Creating privateKeys.json file..."
cat <<EOF > privateKeys.json
[
  "$PRIVATE_KEY_LOCAL"
]
EOF

# Полезные команды
echo "Setup complete! The bot is now running."

echo "Useful commands to manage the bot:"
echo "1. Start the bot: npm start"
echo "2. Run Arbitrum task: npm run arbt"
echo "3. Run Optimism task: npm run opsp"
echo "4. Use Screen to manage the bot session: screen -S bot"
echo "5. Edit the privateKeys.json file: nano privateKeys.json"
