#!/bin/sh

# Setup folders
mkdir -p ../data

# Load model
CMD="./llm_bench.sh http://localhost:1234 'lmstudio' 'qwen3.5-9b-mlx'"
eval $CMD

# Run benchmark
HEADER="model,prompt_tokens,completion_tokens,total_tokens,elapsed_ms,tokens_per_second"
echo "$HEADER" > ../data/lmstudio_llm_bench.csv
(for i in {1..10}; do eval $CMD; done) >> ../data/lmstudio_llm_bench.csv

# Unload model
lms unload 'qwen3.5-9b-mlx'

# Load model
CMD="./llm_bench.sh http://localhost:11434 'ollama' 'qwen3.5:9b'"
eval $CMD

# Run benchmark
echo "$HEADER" > ../data/ollama_llm_bench.csv
(for i in {1..10}; do eval $CMD; done) >> ../data/ollama_llm_bench.csv

# Unload model
curl http://localhost:11434/api/generate -d '{"model": "qwen3.5:9b", "keep_alive": 0}'
