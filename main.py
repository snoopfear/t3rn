from web3 import Web3
import time
import random

# Подключение к провайдеру (замените на ваш URL провайдера)
provider_url = "https://endpoints.omniatech.io/v1/op/sepolia/public"  # op
web3 = Web3(Web3.HTTPProvider(provider_url))

# Проверяем подключение к провайдеру
if not web3.is_connected():
    raise ConnectionError("Failed to connect to the Ethereum network.")

# Адрес отправителя и его приватный ключ
sender_address = ""
private_key = "0xYourPrivateKeyHere"  # Добавьте ваш приватный ключ, начинающийся с "0x"

# Функция для отправки транзакции
def send_transaction():
    try:
        # Получение актуального nonce
        nonce = web3.eth.get_transaction_count(sender_address)
        print(f"Using nonce: {nonce}")

        # Получение текущих параметров газа
        base_fee = web3.eth.get_block("latest")["baseFeePerGas"]
        max_priority_fee = web3.to_wei(2, "gwei")  # Рекомендованная приоритетная плата
        max_fee = base_fee + max_priority_fee

        # Данные транзакции
        transaction = {
            "chainId": 11155420,  # op
            "from": sender_address,
            "to": "0xF221750e52aA080835d2957F2Eed0d5d7dDD8C38",
            "value": web3.to_wei(0.1, "ether"),  # Преобразование значения в wei
            "maxFeePerGas": max_fee,
            "maxPriorityFeePerGas": max_priority_fee,
            "nonce": nonce,
            "data": "0x56591d596273737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000092729Fa252dfDC127C8Aa6b2fc1c3d8465a519430000000000000000000000000000000000000000000000000159fa461978bdff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000016345785d8a0000",
        }

        # Автоматический расчет лимита газа
        transaction["gas"] = web3.eth.estimate_gas(transaction)

        # Подписание транзакции
        signed_tx = web3.eth.account.sign_transaction(transaction, private_key)

        # Отправка транзакции
        tx_hash = web3.eth.send_raw_transaction(signed_tx.rawTransaction)
        print(f"Transaction sent! Hash: {tx_hash.hex()}")

        # Подтверждение транзакции (необязательно)
        receipt = web3.eth.wait_for_transaction_receipt(tx_hash)
        print(f"Transaction {tx_hash.hex()} confirmed in block {receipt['blockNumber']}")
    except Exception as e:
        print(f"Error sending transaction: {str(e)}")

# Основной цикл отправки транзакций
for i in range(1500):
    send_transaction()
    wait_time = random.randint(5, 30)  # Случайная задержка
    print(f"Waiting for {wait_time} seconds...")
    time.sleep(wait_time)
