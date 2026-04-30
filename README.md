# LLM Benchmark Comparison

This project benchmarks and compares the performance of different LLM servers and quantization methods.

## Overview

The benchmark measures **tokens per second** (throughput) for different LLM serving configurations.

## Results

### Tokens Per Second by Server

![Tokens Per Second by Server](images/server_box_plot.png)

### Tokens Per Second by Quantization Method

![Tokens Per Second by Server](images/quant_method_box_plot.png)

## Key Findings

- **lmstudio** (MLX) shows ~2.2x higher tokens per second compared to **ollama** (GGUF)
- **qwen3.5-9b-mlx** shows ~1.6x higher tokens per second compared to **qwen3.5-9b-gguf**

## Data Sources

- `data/lmstudio_llm_bench.csv` - lmstudio benchmark results
- `data/ollama_llm_bench.csv` - ollama benchmark results
- `data/qwen35-9b-mlx_llm_bench.csv` - MLX benchmark results
- `data/qwen35-9b-gguf_llm_bench.csv` - GGUF benchmark results

## Scripts

- `scripts/merge_and_plot.R` - R script for merging datasets and generating the box plot
- `scripts/llm_bench.sh` - Shell script for running benchmarks
- `scripts/llm_test_ollama_vs_lmstudio.sh` - Test script for running benchark N times
- `scripts/llm_test_mlx_vs_gguf.sh` - Test script for running benchark N times

## Usage

Run the benchmark script to generate results:

```bash
cd scripts/
./llm_test_ollama_vs_lmstudio.sh
./llm_test_qwen35-9B_mlx_vs_gguf.sh
```

Generate the comparison plot:

```bash
cd ../
Rscript scripts/merge_and_plot.R
```