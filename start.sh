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
MODEL_PATH="$OLLAMA_MODELS/$MODEL_NAME/$MODEL_VARIANT"

echo "[INFO] Checking for Ollama..."
if ! command -v ollama &> /dev/null; then
    echo "[INFO] Ollama not found. Installing..."
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "[INFO] Ollama already installed."
fi

# Make sure model storage directory exists
mkdir -p "$OLLAMA_MODELS"

# Start Ollama with model dir
echo "[INFO] Starting Ollama..."
ollama serve --model-dir "$OLLAMA_MODELS" &

# Wait for Ollama to spin up
sleep 10

# Check if Gemma 2 27B is already downloaded
if [ -d "$MODEL_PATH" ]; then
    echo "[INFO] Gemma 2 27B already exists in /workspace. Skipping download."
else
    echo "[INFO] Pulling Gemma 2 27B..."
    ollama pull "$MODEL_NAME:$MODEL_VARIANT"
fi

# Ensure Python deps
pip install requests

echo "[INFO] Setup complete. Container is now idling."
tail -f /dev/null
