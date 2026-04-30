#!/bin/sh

# Configure number of test iterations
N=10

# Setup folders
DATA_DIR="../data"
mkdir -p "$DATA_DIR"

# ---- LM Studio Test ----

# Load model
MODEL='qwen3.5-9b-mlx'
CMD="./llm_bench.sh http://localhost:1234 'lmstudio' '$MODEL'"
eval $CMD

# Run benchmark
HEADER="model,prompt_tokens,completion_tokens,total_tokens,elapsed_ms,tokens_per_second"
DATA_FILE="$DATA_DIR/lmstudio_llm_bench.csv"
echo "$HEADER" > "$DATA_FILE"
(for i in $(seq 1 ${N}); do eval $CMD; done) >> "$DATA_FILE"

# Unload model
MODELID=$(lms ps | grep "$MODEL" | cut -d" " -f 1)
lms unload "$MODELID"

# ---- Ollama Test ----

# Load model
MODEL='qwen3.5:9b'
CMD="./llm_bench.sh http://localhost:11434 'ollama' '$MODEL'"
eval $CMD

# Run benchmark
DATA_FILE="$DATA_DIR/ollama_llm_bench.csv"
echo "$HEADER" > "$DATA_FILE"
(for i in $(seq 1 ${N}); do eval $CMD; done) >> "$DATA_FILE"

# Unload model
ollama stop "$MODEL"
