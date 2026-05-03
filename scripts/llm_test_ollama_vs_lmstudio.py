#!/usr/bin/env python3
"""
Python script to benchmark LM Studio vs Ollama servers.
Replicates the functionality of llm_test_ollama_vs_lmstudio.sh shell script.

Usage:
    python llm_test_ollama_vs_lmstudio.py [N]

Arguments:
    N - Number of test iterations (default: 10)
"""

import sys
import os
import subprocess

# Default number of iterations
N = int(sys.argv[1]) if len(sys.argv) > 1 else 10

# Setup folders
data_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data")
os.makedirs(data_dir, exist_ok=True)

# ---- LM Studio Test ----

print("=== LM Studio Test ===")

# Load model
model = 'qwen3.5-9b-mlx'
cmd = ["python", "llm_bench.py", "http://localhost:1234", "lmstudio", model]
print(f"Running: {' '.join(cmd)}")

# Warm up model (run once before benchmarking)
print("Warming up model...")
result = subprocess.run(cmd, capture_output=True, text=True)
if result.returncode != 0:
    print(f"Warning: Warm-up failed: {result.stderr}", file=sys.stderr)

# Run benchmark
header = "model,prompt_tokens,completion_tokens,total_tokens,elapsed_ms,tokens_per_second"
data_file = os.path.join(data_dir, "lmstudio_llm_bench.csv")

with open(data_file, 'w') as f:
    f.write(header + "\n")
    for i in range(1, N + 1):
        print(f"Iteration {i}/{N}...")
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            f.write(result.stdout.strip() + "\n")
        else:
            print(f"Error on iteration {i}: {result.stderr}", file=sys.stderr)

print(f"LM Studio results saved to {data_file}")

# Unload model (using lms command)
print("Unloading LM Studio model...")
try:
    result = subprocess.run(["lms", "ps"], capture_output=True, text=True)
    for line in result.stdout.strip().split('\n'):
        if model in line:
            model_id = line.split()[0]
            subprocess.run(["lms", "unload", model_id])
            print(f"Unloaded model with ID: {model_id}")
            break
except Exception as e:
    print(f"Warning: Could not unload LM Studio model: {e}")

# ---- Ollama Test ----

print("\n=== Ollama Test ===")

# Load model
model = 'qwen3.5:9b'
cmd = ["python", "llm_bench.py", "http://localhost:11434", "ollama", model]
print(f"Running: {' '.join(cmd)}")

# Warm up model (run once before benchmarking)
print("Warming up model...")
result = subprocess.run(cmd, capture_output=True, text=True)
if result.returncode != 0:
    print(f"Warning: Warm-up failed: {result.stderr}", file=sys.stderr)

# Run benchmark
data_file = os.path.join(data_dir, "ollama_llm_bench.csv")

with open(data_file, 'w') as f:
    f.write(header + "\n")
    for i in range(1, N + 1):
        print(f"Iteration {i}/{N}...")
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            f.write(result.stdout.strip() + "\n")
        else:
            print(f"Error on iteration {i}: {result.stderr}", file=sys.stderr)

print(f"Ollama results saved to {data_file}")

# Unload model (using ollama command)
print("Unloading Ollama model...")
try:
    subprocess.run(["ollama", "stop", model])
except Exception as e:
    print(f"Warning: Could not stop Ollama model: {e}")

print("\n=== Benchmark Complete ===")