#!/bin/bash

# Подгружаем переменные окружения
source ~/.bashrc

echo "Установка необходимых библиотек..."
pip3 install web3 tqdm

echo "Создание папки проекта..."
mkdir -p ~/any-arb
cd ~/any-arb

echo "Создание main.py..."
cat > main.py << 'EOF'
import os
import random
import time
from web3 import Web3

# Загрузка приватного ключа и APIKEY из переменных окружения
PRIVATE_KEY = os.getenv('PRIVATE_KEY_LOCAL')
APIKEY = os.getenv('APIKEY')

if not PRIVATE_KEY:
    raise Exception('Ошибка: PRIVATE_KEY_LOCAL не найден в окружении!')

if not APIKEY:
    raise Exception('Ошибка: APIKEY не найден в окружении!')

RPCS = {
    'opt': f'https://opt-sepolia.g.alchemy.com/v2/{APIKEY}',
    'base': f'https://base-sepolia.g.alchemy.com/v2/{APIKEY}',
    'uni': f'https://unichain-sepolia.g.alchemy.com/v2/{APIKEY}',
}

TX_DATAS = {
    'opt': '0x56591d5961726274000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000189b27215bC6c8d842A4D320fcb232ce8A0760130000000000000000000000000000000000000000000000000dde4f3abc938436000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000de0b6b3a7640000',
    'base': '0x56591d5961726274000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000189b27215bC6c8d842A4D320fcb232ce8A0760130000000000000000000000000000000000000000000000000de076b510f59707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000de0b6b3a7640000',
    'uni': '0x56591d5961726274000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000189b27215bC6c8d842A4D320fcb232ce8A0760130000000000000000000000000000000000000000000000000de076b706379126000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000de0b6b3a7640000',
}

CHAIN_IDS = {
    'opt': 11155420,
    'base': 84532,
    'uni': 11155420,
}

BALANCE_LIMIT = 0.1

web3_objects = {name: Web3(Web3.HTTPProvider(rpc)) for name, rpc in RPCS.items()}

for name, w3 in web3_objects.items():
    if not w3.is_connected():
        raise Exception(f'Ошибка подключения к {name} сети!')

SENDER_ADDRESS = web3_objects['opt'].eth.account.from_key(PRIVATE_KEY).address
TO_ADDRESS = SENDER_ADDRESS

def get_eth_balance(w3: Web3):
    balance_wei = w3.eth.get_balance(SENDER_ADDRESS)
    return w3.from_wei(balance_wei, 'ether')

def build_and_send_tx(w3: Web3, chain: str):
    for attempt in range(3):
        try:
            nonce = w3.eth.get_transaction_count(SENDER_ADDRESS, 'pending')
            latest_block = w3.eth.get_block('latest')
            base_fee = latest_block.get('baseFeePerGas', w3.to_wei(1, 'gwei'))
            priority_fee = w3.to_wei(0.00097 * random.uniform(1.01, 1.05), 'gwei')

            tx = {
                'chainId': CHAIN_IDS[chain],
                'nonce': nonce,
                'to': TO_ADDRESS,
                'value': w3.to_wei(0.001, 'ether'),
                'gas': 1400000,
                'maxFeePerGas': base_fee + priority_fee,
                'maxPriorityFeePerGas': priority_fee,
                'type': 2,
                'data': TX_DATAS[chain],
            }

            signed_tx = w3.eth.account.sign_transaction(tx, private_key=PRIVATE_KEY)
            tx_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)

            print(f'[{chain.upper()}] Транзакция отправлена: {w3.to_hex(tx_hash)}')
            return

        except Exception as e:
            error_message = str(e)
            if 'nonce too low' in error_message:
                print(f'[{chain.upper()}] Nonce too low, пробуем снова...')
                time.sleep(1)
                continue
            elif 'replacement transaction underpriced' in error_message:
                print(f'[{chain.upper()}] Underpriced, увеличиваем приоритет...')
                time.sleep(1)
                continue
            else:
                print(f'[{chain.upper()}] Неизвестная ошибка: {error_message}')
                break

    print(f'[{chain.upper()}] Не удалось отправить транзакцию после 3 попыток.')

while True:
    balances = {name: get_eth_balance(w3) for name, w3 in web3_objects.items()}
    print(f'Баланс: {balances}')

    if any(balance <= BALANCE_LIMIT for balance in balances.values()):
        print('Достигнут лимит баланса, останавливаем скрипт.')
        break

    chain_choice = random.choice(list(RPCS.keys()))
    build_and_send_tx(web3_objects[chain_choice], chain_choice)

    delay = random.uniform(1, 5)
    print(f'Ждем {delay:.2f} секунд перед следующей транзакцией...')
    time.sleep(delay)
EOF

echo "✅ Установка завершена."
echo "cd ~/any-arb"
echo "Запустить скрипт: python3 main.py"
echo "screen -S any-arb"
echo "nano main.py"
