#!/bin/bash

# Fail fast
set -e

echo "[INFO] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

# Start Ollama in background
ollama serve &

# Wait a bit for Ollama to spin up
sleep 10

echo "[INFO] Pulling Gemma 2 27B..."
ollama pull gemma2:27b

pip install requests

echo "[INFO] Gemma 2 27B is ready. Container is now idling."
tail -f /dev/null
