#!/usr/bin/env python3
"""
Python script to benchmark multiple Qwen models with MLX quantization.
Replicates the functionality of llm_test_qwen-series_mlx.sh shell script.

Usage:
    python llm_test_qwen_series_mlx.py [N]

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

# Models to test
models = [
    ('qwen3.5-9b-mlx', 'qwen35-9b-mlx-4bit'),
    ('qwen3-14b-mlx', 'qwen3-14b-mlx-4bit'),
    ('qwen3-8b-mlx', 'qwen3-8b-mlx-4bit'),
    ('qwen3-4b-instruct-2507-mlx', 'qwen3-4b-instruct-2507-mlx-4bit'),
    ('qwen2.5-coder-14b-instruct-mlx', 'qwen25-coder-14b-instruct-mlx-4bit'),
    ('qwen2.5-7b-instruct-mlx', 'qwen25-7b-instruct-mlx-4bit'),
]

header = "model,prompt_tokens,completion_tokens,total_tokens,elapsed_ms,tokens_per_second"

for model, filename in models:
    print(f"\n=== Testing {model} ===")
    
    # Warm up model (run once before benchmarking)
    cmd = ["python", "llm_bench.py", "http://localhost:1234", "lmstudio", model]
    print(f"Running: {' '.join(cmd)}")
    print("Warming up model...")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Warning: Warm-up failed: {result.stderr}", file=sys.stderr)
    
    # Run benchmark
    data_file = os.path.join(data_dir, f"{filename}_llm_bench.csv")
    
    with open(data_file, 'w') as f:
        f.write(header + "\n")
        for i in range(1, N + 1):
            print(f"Iteration {i}/{N}...")
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                f.write(result.stdout.strip() + "\n")
            else:
                print(f"Error on iteration {i}: {result.stderr}", file=sys.stderr)
    
    print(f"Results saved to {data_file}")
    
    # Unload model
    print(f"Unloading {model}...")
    try:
        result = subprocess.run(["lms", "ps"], capture_output=True, text=True)
        for line in result.stdout.strip().split('\n'):
            if model in line:
                model_id = line.split()[0]
                subprocess.run(["lms", "unload", model_id])
                print(f"Unloaded model with ID: {model_id}")
                break
    except Exception as e:
        print(f"Warning: Could not unload model: {e}")

print("\n=== Benchmark Complete ===")