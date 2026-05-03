#!/bin/sh

# Configure number of test iterations
N=10

# Setup folders
DATA_DIR="../data"
mkdir -p "$DATA_DIR"

# ---- Qwen3.5-9B-MLX-4bit ----

# Load model
MODEL='qwen3.5-9b-mlx'
CMD="./llm_bench.sh http://localhost:1234 'lmstudio' '$MODEL'"
eval $CMD

# Run benchmark
HEADER="model,prompt_tokens,completion_tokens,total_tokens,elapsed_ms,tokens_per_second"
DATA_FILE="$DATA_DIR/qwen35-9b-mlx-4bit_llm_bench.csv"
echo "$HEADER" > "$DATA_FILE"
(for i in $(seq 1 ${N}); do eval $CMD; done) >> "$DATA_FILE"

# Unload model
MODELID=$(lms ps | grep "$MODEL" | cut -d" " -f 1)
lms unload "$MODELID"


# ---- Qwen3-14B-MLX-4bit ----

# Load model
MODEL='qwen3-14b-mlx'
CMD="./llm_bench.sh http://localhost:1234 'lmstudio' '$MODEL'"
eval $CMD

# Run benchmark
HEADER="model,prompt_tokens,completion_tokens,total_tokens,elapsed_ms,tokens_per_second"
DATA_FILE="$DATA_DIR/qwen3-14b-mlx-4bit_llm_bench.csv"
echo "$HEADER" > "$DATA_FILE"
(for i in $(seq 1 ${N}); do eval $CMD; done) >> "$DATA_FILE"

# Unload model
MODELID=$(lms ps | grep "$MODEL" | cut -d" " -f 1)
lms unload "$MODELID"

# ---- Qwen3-8B-MLX-4bit ----

# Load model
MODEL='qwen3-8b-mlx'
CMD="./llm_bench.sh http://localhost:1234 'lmstudio' '$MODEL'"
eval $CMD

# Run benchmark
HEADER="model,prompt_tokens,completion_tokens,total_tokens,elapsed_ms,tokens_per_second"
DATA_FILE="$DATA_DIR/qwen3-8b-mlx-4bit_llm_bench.csv"
echo "$HEADER" > "$DATA_FILE"
(for i in $(seq 1 ${N}); do eval $CMD; done) >> "$DATA_FILE"

# Unload model
MODELID=$(lms ps | grep "$MODEL" | cut -d" " -f 1)
lms unload "$MODELID"

# ---- Qwen3-4B-Instruct-2507-MLX-4bit ----

# Load model
MODEL='qwen3-4b-instruct-2507-mlx'
CMD="./llm_bench.sh http://localhost:1234 'lmstudio' '$MODEL'"
eval $CMD

# Run benchmark
HEADER="model,prompt_tokens,completion_tokens,total_tokens,elapsed_ms,tokens_per_second"
DATA_FILE="$DATA_DIR/qwen3-4b-instruct-2507-mlx-4bit_llm_bench.csv"
echo "$HEADER" > "$DATA_FILE"
(for i in $(seq 1 ${N}); do eval $CMD; done) >> "$DATA_FILE"

# Unload model
MODELID=$(lms ps | grep "$MODEL" | cut -d" " -f 1)
lms unload "$MODELID"

# ---- Qwen2.5-Coder-14B-Instruct-MLX-4bit ----

# Load model
MODEL='qwen2.5-coder-14b-instruct-mlx'
CMD="./llm_bench.sh http://localhost:1234 'lmstudio' '$MODEL'"
eval $CMD

# Run benchmark
HEADER="model,prompt_tokens,completion_tokens,total_tokens,elapsed_ms,tokens_per_second"
DATA_FILE="$DATA_DIR/qwen25-coder-14b-instruct-mlx-4bit_llm_bench.csv"
echo "$HEADER" > "$DATA_FILE"
(for i in $(seq 1 ${N}); do eval $CMD; done) >> "$DATA_FILE"

# Unload model
MODELID=$(lms ps | grep "$MODEL" | cut -d" " -f 1)
lms unload "$MODELID"

# ---- Qwen2.5-7B-Instruct-MLX-4bit ----

# Load model
MODEL='qwen2.5-7b-instruct-mlx'
CMD="./llm_bench.sh http://localhost:1234 'lmstudio' '$MODEL'"
eval $CMD

# Run benchmark
HEADER="model,prompt_tokens,completion_tokens,total_tokens,elapsed_ms,tokens_per_second"
DATA_FILE="$DATA_DIR/qwen25-7b-instruct-mlx-4bit_llm_bench.csv"
echo "$HEADER" > "$DATA_FILE"
(for i in $(seq 1 ${N}); do eval $CMD; done) >> "$DATA_FILE"

# Unload model
MODELID=$(lms ps | grep "$MODEL" | cut -d" " -f 1)
lms unload "$MODELID"
