#!/usr/bin/env python3
"""
Python script to merge datasets and create bar plots for LLM benchmark comparison.
This replicates the functionality of merge_and_plot.R.
"""

import os
import glob
import pandas as pd
import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend for headless systems
import matplotlib.pyplot as plt

# Setup folder paths
data_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data")
images_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "images")

# Create images directory if it doesn't exist
os.makedirs(images_dir, exist_ok=True)

# Read the datasets
lmstudio_data = pd.read_csv(os.path.join(data_dir, "lmstudio_llm_bench.csv"))
ollama_data = pd.read_csv(os.path.join(data_dir, "ollama_llm_bench.csv"))
mlx_data = pd.read_csv(os.path.join(data_dir, "qwen35-9b-mlx_llm_bench.csv"))
gguf_data = pd.read_csv(os.path.join(data_dir, "qwen35-9b-gguf_llm_bench.csv"))

# Read Qwen series data files
qwen_data_files = [
    "qwen35-9b-mlx-4bit_llm_bench.csv",
    "qwen3-14b-mlx-4bit_llm_bench.csv",
    "qwen3-8b-mlx-4bit_llm_bench.csv",
    "qwen3-4b-instruct-2507-mlx-4bit_llm_bench.csv",
    "qwen25-coder-14b-instruct-mlx-4bit_llm_bench.csv",
    "qwen25-7b-instruct-mlx-4bit_llm_bench.csv"
]

qwen_data_list = []
for filename in qwen_data_files:
    filepath = os.path.join(data_dir, filename)
    if os.path.exists(filepath):
        df = pd.read_csv(filepath)
        qwen_data_list.append(df)

qwen_data = pd.concat(qwen_data_list, ignore_index=True)

# Add a source column to distinguish the datasets
lmstudio_data['source'] = "LM Studio"
ollama_data['source'] = "Ollama"
mlx_data['source'] = "MLX"
gguf_data['source'] = "GGUF"
qwen_data['source'] = qwen_data['model']

# Merge the datasets by combining them
merged_data_server = pd.concat([lmstudio_data, ollama_data], ignore_index=True)
merged_data_quant_method = pd.concat([mlx_data, gguf_data], ignore_index=True)

# ============================================
# Create bar plot with one bar for each server
# ============================================
aggregated_data_server = merged_data_server.groupby('source').agg(
    tokens_per_second=('tokens_per_second', 'mean')
).reset_index()

# Sort by tokens_per_second descending
aggregated_data_server = aggregated_data_server.sort_values('tokens_per_second', ascending=False)

fig1, ax1 = plt.subplots(figsize=(5, 4))
colors_server = {'LM Studio': '#3498db', 'Ollama': '#e74c3c'}
bars = ax1.bar(
    aggregated_data_server['source'],
    aggregated_data_server['tokens_per_second'],
    color=[colors_server[s] for s in aggregated_data_server['source']]
)

# Add value labels on bars
for bar, val in zip(bars, aggregated_data_server['tokens_per_second']):
    ax1.text(
        bar.get_x() + bar.get_width() / 2,
        bar.get_height() + 0.5,
        f'{val:.2f}',
        ha='center',
        va='bottom',
        color='black'
    )

ax1.set_xlabel('Server')
ax1.set_ylabel('Tokens Per Second (tokens/sec)')
ax1.set_title('Speed Test: LM Studio (MLX) vs. Ollama (GGUF)\nUsing Qwen3.5 9B on a 16 GB M1 Pro MacBook Pro')
ax1.set_ylim(0, max(aggregated_data_server['tokens_per_second']) * 1.2)
ax1.tick_params(axis='x', rotation=0)

# Remove legend if it exists
legend = ax1.get_legend()
if legend is not None:
    legend.remove()

plt.tight_layout()
server_image_file = os.path.join(images_dir, "server_bar_plot.png")
plt.savefig(server_image_file, dpi=300, bbox_inches='tight')
plt.close()

# Print the speed ratio of LM Studio vs. Ollama
print("Speed ratio: LM Studio (MLX) vs. Ollama (GGUF)")
lmstudio_mean = lmstudio_data['tokens_per_second'].mean()
ollama_mean = ollama_data['tokens_per_second'].mean()
print(lmstudio_mean / ollama_mean)

# ============================================
# Create bar plot with one bar for each quantization method
# ============================================
aggregated_data_quant_method = merged_data_quant_method.groupby('source').agg(
    tokens_per_second=('tokens_per_second', 'mean')
).reset_index()

# Sort by tokens_per_second descending
aggregated_data_quant_method = aggregated_data_quant_method.sort_values('tokens_per_second', ascending=False)

fig2, ax2 = plt.subplots(figsize=(5, 4))
colors_quant = {'MLX': '#3498db', 'GGUF': '#e74c3c'}
bars = ax2.bar(
    aggregated_data_quant_method['source'],
    aggregated_data_quant_method['tokens_per_second'],
    color=[colors_quant[s] for s in aggregated_data_quant_method['source']]
)

# Add value labels on bars
for bar, val in zip(bars, aggregated_data_quant_method['tokens_per_second']):
    ax2.text(
        bar.get_x() + bar.get_width() / 2,
        bar.get_height() + 0.5,
        f'{val:.2f}',
        ha='center',
        va='bottom',
        color='black'
    )

ax2.set_xlabel('Quantization Method')
ax2.set_ylabel('Tokens Per Second (tokens/sec)')
ax2.set_title('Quantization Speed Test: MLX vs. GGUF\nUsing Qwen3.5 9B with LM Studio on a 16 GB M1 Pro MacBook Pro')
ax2.set_ylim(0, max(aggregated_data_quant_method['tokens_per_second']) * 1.2)
ax2.tick_params(axis='x', rotation=0)

# Remove legend if it exists
legend = ax2.get_legend()
if legend is not None:
    legend.remove()

plt.tight_layout()
quant_method_image_file = os.path.join(images_dir, "quant_method_bar_plot.png")
plt.savefig(quant_method_image_file, dpi=300, bbox_inches='tight')
plt.close()

# Print the speed ratio of MLX vs. GGUF with LM Studio
print("Speed ratio: MLX vs. GGUF (both served by LM Studio)")
mlx_mean = mlx_data['tokens_per_second'].mean()
gguf_mean = gguf_data['tokens_per_second'].mean()
print(mlx_mean / gguf_mean)

# ============================================
# Create bar plot with one bar for each Qwen model
# ============================================
aggregated_data_qwen = qwen_data.groupby('source').agg(
    tokens_per_second=('tokens_per_second', 'mean')
).reset_index()

# Sort by tokens_per_second ascending (for horizontal bar chart with ascending order)
aggregated_data_qwen = aggregated_data_qwen.sort_values('tokens_per_second', ascending=True)

fig3, ax3 = plt.subplots(figsize=(5, 4))
bars = ax3.barh(
    aggregated_data_qwen['source'],
    aggregated_data_qwen['tokens_per_second'],
    color='#3498db'
)

# Add value labels on bars (hjust=1.2 in ggplot means labels are placed to the right of bars)
for bar, val in zip(bars, aggregated_data_qwen['tokens_per_second']):
    ax3.text(
        bar.get_width() + 0.5,
        bar.get_y() + bar.get_height() / 2,
        f'{val:.2f}',
        ha='left',
        va='center',
        color='black'
    )

ax3.set_xlabel('Tokens Per Second (tokens/sec)')
ax3.set_ylabel('Model')
ax3.set_title('Speed Test: Qwen Models (MLX, 4-bit)\nUsing LM Studio on a 16 GB M1 Pro MacBook Pro')

# Set x-axis limit to widen the plot border
ax3.set_xlim(0, 60)

# Adjust layout to prevent label overlap with plot border
plt.tight_layout(pad=2.0)
# Increase right margin for horizontal bar labels
plt.subplots_adjust(right=0.85)
qwen_image_file = os.path.join(images_dir, "qwen_bar_plot.png")
plt.savefig(qwen_image_file, dpi=300, bbox_inches='tight')
plt.close()

print(f"\nPlots saved to {images_dir}/")
print(f"  - {server_image_file}")
print(f"  - {quant_method_image_file}")
print(f"  - {qwen_image_file}")