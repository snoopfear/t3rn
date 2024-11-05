#!/bin/bash

echo "Welcome to the t3rn Executor Setup by snoopfear!"

cd $HOME
rm -rf ~/executor
sudo apt -q update
sudo apt -qy upgrade

EXECUTOR_URL="https://github.com/t3rn/executor-release/releases/download/v0.22.0/executor-linux-v0.22.0.tar.gz"
EXECUTOR_FILE="executor-linux-v0.22.0.tar.gz"

echo "Downloading the Executor binary from $EXECUTOR_URL..."
curl -L -o $EXECUTOR_FILE $EXECUTOR_URL

if [ $? -ne 0 ]; then
    echo "Failed to download the Executor binary. Please check your internet connection and try again."
    exit 1
fi

echo "Extracting the binary..."
tar -xzvf $EXECUTOR_FILE
rm -rf $EXECUTOR_FILE

echo "Setup complete! The Executor was installed."
