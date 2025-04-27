#!/bin/bash

# Скрипт установки Python, зависимостей и твоего проекта

set -e  # остановиться при любой ошибке

echo "Обновление системы..."
sudo apt update && sudo apt upgrade -y

echo "Установка Python и pip..."
sudo apt install -y python3 python3-pip

echo "Установка необходимых библиотек..."
pip3 install --upgrade pip
pip3 install web3 tqdm

echo "Создание папки проекта..."
mkdir -p ~/op-uni
cd ~/op-uni

echo "Создание main.py..."
cat > main.py << 'EOF'
import random
import time
from tqdm import tqdm
from web3 import Web3
from web3.exceptions import Web3RPCError
import os

# RPC фиксированный
RPC_URL = "https://sepolia.optimism.io"

# Переменные окружения
PRIVATE_KEY = os.getenv('PRIVATE_KEY_LOCAL')

# Проверка на наличие приватника
if PRIVATE_KEY is None:
    raise Exception('Ошибка: PRIVATE_KEY_LOCAL не найден в окружении!')

# Инициализация Web3
web3 = Web3(Web3.HTTPProvider(RPC_URL))

if not web3.is_connected():
    raise Exception('Ошибка подключения к RPC!')

# Получаем адрес отправителя из приватного ключа
SENDER_ADDRESS = web3.eth.account.from_key(PRIVATE_KEY).address

# TO_ADDRESS = SENDER_ADDRESS
TO_ADDRESS = SENDER_ADDRESS

# Массив transaction_data
transaction_data_list = [
    "",
    ""
]

print(f'Подключено к сети. Баланс: {web3.from_wei(web3.eth.get_balance(SENDER_ADDRESS), "ether")} ETH')

successful_uni = 0
successful_base = 0

N = 1000  # Количество транзакций

def send_tx(transaction_data_index):
    global successful_uni, successful_base

    for attempt in range(3):
        try:
            nonce = web3.eth.get_transaction_count(SENDER_ADDRESS, 'pending')
            latest_block = web3.eth.get_block('latest')
            base_fee = latest_block['baseFeePerGas']
            priority_fee = web3.to_wei(0.00097 * random.uniform(1.01, 1.05), 'gwei')

            tx = {
                'chainId': 11155420,
                'nonce': nonce,
                'to': TO_ADDRESS,
                'value': web3.to_wei(1, 'ether'),
                'gas': 1400000,
                'maxFeePerGas': base_fee + priority_fee,
                'maxPriorityFeePerGas': priority_fee,
                'type': 2,
                'data': transaction_data_list[transaction_data_index]
            }

            signed_tx = web3.eth.account.sign_transaction(tx, private_key=PRIVATE_KEY)
            tx_hash = web3.eth.send_raw_transaction(signed_tx.raw_transaction)

            print(f'Транзакция отправлена: {web3.to_hex(tx_hash)}')

            if transaction_data_index == 0:
                successful_uni += 1
            else:
                successful_base += 1

            return

        except Web3RPCError as e:
            error_message = str(e)
            if 'nonce too low' in error_message:
                print('Nonce too low, пробуем снова...')
                time.sleep(1)
                continue
            elif 'replacement transaction underpriced' in error_message:
                print('Replacement transaction underpriced, увеличиваем приоритет...')
                time.sleep(1)
                continue
            else:
                print(f'Неизвестная ошибка: {error_message}')
                break

    print('Не удалось отправить транзакцию после 3 попыток.')

# Основной цикл
for i in tqdm(range(N), desc="Отправка транзакций"):
    transaction_data_index = i % 2
    send_tx(transaction_data_index)
    time.sleep(random.randint(5, 10))  # задержка между отправками

print(f"\nУспешно отправлено транзакций:")
print(f"UNI: {successful_uni}")
print(f"BASE: {successful_base}")
EOF

echo "✅ Установка завершена."
echo "Перейти в папку проекта: cd ~/op-uni"
echo "Запустить скрипт: python3 main.py"
