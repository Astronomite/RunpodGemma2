#!/bin/bash

# Fail fast
set -e

echo "[INFO] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# Set Ollama to store models in /workspace/ollama
export OLLAMA_MODELS=/workspace/ollama

# Create directory if it doesn't exist
mkdir -p "$OLLAMA_MODELS"

# Start Ollama with custom model dir
ollama serve --model-dir "$OLLAMA_MODELS" &

# Wait a bit for Ollama to spin up
sleep 10

echo "[INFO] Pulling Gemma 2 27B..."
ollama pull gemma2:27b

pip install requests

echo "[INFO] Gemma 2 27B is ready. Container is now idling."
tail -f /dev/null
