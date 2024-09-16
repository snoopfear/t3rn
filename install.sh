#!/bin/bash


echo "Welcome to the t3rn Executor Setup by snoopfear!"

cd $HOME
rm -rf executor
sudo apt -q update
sudo apt -qy upgrade

EXECUTOR_URL="https://github.com/t3rn/executor-release/releases/download/v0.21.0/executor-linux-v0.21.0.tar.gz"
EXECUTOR_FILE="executor-linux-v0.21.0.tar.gz"

echo "Downloading the Executor binary from $EXECUTOR_URL..."
curl -L -o $EXECUTOR_FILE $EXECUTOR_URL

if [ $? -ne 0 ]; then
    echo "Failed to download the Executor binary. Please check your internet connection and try again."
    exit 1
fi

echo "Extracting the binary..."
tar -xzvf $EXECUTOR_FILE
rm -rf $EXECUTOR_FILE
cd executor/executor/bin

echo "Binary downloaded and extracted successfully."
echo


export NODE_ENV=testnet
echo "Node Environment set to: testnet"
echo

export LOG_LEVEL=debug
export LOG_PRETTY=false
echo "Log settings configured: LOG_LEVEL=$LOG_LEVEL, LOG_PRETTY=$LOG_PRETTY"
echo

read -p "Enter your Private Key from Metamask: " PRIVATE_KEY_LOCAL
export PRIVATE_KEY_LOCAL=$PRIVATE_KEY_LOCAL
echo -e "\nPrivate key has been set."
echo

export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,l1rn'
echo "Enabled Networks set to: $ENABLED_NETWORKS"
echo

#export EXECUTOR_ARBITRUM_SEPOLIA_RPC_URLS='https://arb-sepolia.g.alchemy.com/v2/lNTUkf8We6CAI3gpMaBGyPsSz7bRk2U1'
#export EXECUTOR_OPTIMISM_SEPOLIA_RPC_URLS='https://opt-sepolia.g.alchemy.com/v2/lNTUkf8We6CAI3gpMaBGyPsSz7bRk2U1'
#export EXECUTOR_BASE_SEPOLIA_RPC_URLS='https://base-sepolia.g.alchemy.com/v2/lNTUkf8We6CAI3gpMaBGyPsSz7bRk2U1'
#export EXECUTOR_BLAST_SEPOLIA_RPC_URLS='https://blast-sepolia.g.alchemy.com/v2/lNTUkf8We6CAI3gpMaBGyPsSz7bRk2U1'

echo "Starting the Executor..."
./executor

rm t3rn.sh
echo "Setup complete! The Executor is now running."
