#!/bin/bash

echo "Welcome to the t3rn Bot Setup by snoopfear!"

# Установка необходимых пакетов
echo "Updating package list and installing necessary packages..."
sudo apt -q update
sudo apt -qy install git curl build-essential

# Проверка на существование переменной PRIVATE_KEY_LOCAL
if [ -z "${PRIVATE_KEY_LOCAL}" ]; then
    # Запрос ввода приватного ключа
    read -p "Enter your Private Key from Metamask: " PRIVATE_KEY_LOCAL
    # Экспорт переменной
    export PRIVATE_KEY_LOCAL
else
    echo "Using existing PRIVATE_KEY_LOCAL: $PRIVATE_KEY_LOCAL"
fi

# Установка nvm (Node Version Manager)
echo "Installing nvm (Node Version Manager)..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

# Загрузка nvm в текущую сессию
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Установка последней версии Node.js и npm
echo "Installing the latest version of Node.js and npm..."
nvm install node

# Проверка установки Node.js и npm
echo "Checking Node.js and npm versions..."
node -v
npm -v

# Клонирование репозитория
echo "Cloning the repository..."
git clone https://github.com/snoopfear/t3rn-airdrop-bot.git || { echo "Failed to clone repository. Exiting."; exit 1; }

# Переход в директорию
if [ -d "t3rn-airdrop-bot" ]; then
    cd t3rn-airdrop-bot || { echo "Failed to change directory. Exiting."; exit 1; }
else
    echo "Directory t3rn-airdrop-bot does not exist. Exiting."
    exit 1
fi

# Установка зависимостей
echo "Installing dependencies..."
npm install || { echo "Failed to install dependencies. Exiting."; exit 1; }

# Создание файла privateKeys.json
echo "Creating privateKeys.json file..."
cat <<EOF > privateKeys.json
[
  "$PRIVATE_KEY_LOCAL"
]
EOF

# Полезные команды
echo "Setup complete! The bot is now ready."

echo "Useful commands to manage the bot:"
echo "1. Start the bot: npm start"
echo "2. Run Arbitrum task: npm run arbt"
echo "3. Run Optimism task: npm run opsp"
echo "4. Use Screen to manage the bot session: screen -S bot"
echo "5. Edit the privateKeys.json file: nano privateKeys.json"

# Переход в папку t3rn-airdrop-bot (хотя мы уже в ней)
cd t3rn-airdrop-bot || { echo "Failed to change directory. Exiting."; exit 1; }

# Открытие файла privateKeys.json в редакторе nano
echo "Opening privateKeys.json for editing..."
nano privateKeys.json
