#!/bin/bash

# Fail fast
set -e

# Create rclone config directory if needed
mkdir -p /workspace/rclone_config

# If config doesn't exist, prompt user to create or restore
if [ ! -f /workspace/rclone_config/rclone.conf ]; then
    echo "[WARN] No rclone config found at /workspace/rclone_config/rclone.conf"
    echo "Run 'rclone config --config /workspace/rclone_config/rclone.conf' to set it up."
fi

# Point rclone to the persistent config
export RCLONE_CONFIG=/workspace/rclone_config/rclone.conf

# Define Ollama model storage directory
export OLLAMA_MODELS=/workspace/ollama
MODEL_NAME="gemma2"
MODEL_VARIANT="27b"

# Check available disk space (~30GB needed for gemma2:27b)
required_space=30000000  # ~30GB in KB
available_space=$(df -k /workspace | tail -1 | awk '{print $4}')
if [ "$available_space" -lt "$required_space" ]; then
    echo "[ERROR] Insufficient disk space in /workspace. Need ~30GB, available: $((available_space/1024))MB."
    exit 1
fi

# Make sure model storage directory exists
mkdir -p "$OLLAMA_MODELS"

# Check for Ollama installation
echo "[INFO] Checking for Ollama..."
if ! command -v ollama &> /dev/null; then
    echo "[INFO] Ollama not found. Installing..."
    if ! curl -fsSL https://ollama.com/install.sh | sh; then
        echo "[ERROR] Failed to install Ollama."
        exit 1
    fi
    if ! command -v ollama &> /dev/null; then
        echo "[ERROR] Ollama installation failed. Command not found."
        exit 1
    fi
else
    echo "[INFO] Ollama already installed."
fi

# Start Ollama server
echo "[INFO] Starting Ollama server..."
ollama serve &

# Wait for Ollama server to be ready
echo "[INFO] Waiting for Ollama server to be ready..."
timeout=60
elapsed=0
until curl -s http://localhost:11434 >/dev/null; do
    if [ $elapsed -ge $timeout ]; then
        echo "[ERROR] Ollama server did not start within $timeout seconds."
        exit 1
    fi
    sleep 2
    elapsed=$((elapsed + 2))
done
echo "[INFO] Ollama server is ready."

# Check if Gemma 2 27B is already downloaded
if ollama list | grep -q "$MODEL_NAME:$MODEL_VARIANT"; then
    echo "[INFO] Gemma 2 27B already exists. Skipping download."
else
    echo "[INFO] Pulling Gemma 2 27B..."
    ollama pull "$MODEL_NAME:$MODEL_VARIANT"
fi

# Ensure Python dependencies
pip3 install requests

echo "[INFO] Setup complete. Container is now idling."
tail -f /dev/null
