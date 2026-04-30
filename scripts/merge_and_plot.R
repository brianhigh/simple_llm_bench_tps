# R script to merge datasets and create box plot by server

# Load required libraries
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(here)

# Read the datasets
lmstudio_data <- read_csv(here("data", "lmstudio_llm_bench.csv"), show_col_types = FALSE)
ollama_data <- read_csv(here("data", "ollama_llm_bench.csv"), show_col_types = FALSE)
mlx_data <- read_csv(here("data", "qwen35-9b-mlx_llm_bench.csv"), show_col_types = FALSE)
gguf_data <- read_csv(here("data", "qwen35-9b-gguf_llm_bench.csv"), show_col_types = FALSE)

# Add a source column to distinguish the datasets
lmstudio_data$source <- "lmstudio"
ollama_data$source <- "ollama"
mlx_data$source <- "qwen3.5-9b-mlx"
gguf_data$source <- "qwen3.5-9b-gguf"

# Merge the datasets by combining them
merged_data_server <- bind_rows(lmstudio_data, ollama_data)
merged_data_quant_method <- bind_rows(mlx_data, gguf_data)

# Create box plot with one box for each server
p1 <- ggplot(merged_data_server, aes(x = source, y = tokens_per_second, fill = source)) +
  geom_boxplot(width = 0.6) +
  labs(
    title = "Tokens Per Second by Server",
    x = "Server",
    y = "Tokens Per Second (tokens/sec)"
  ) + 
  ylim(0, max(merged_data$tokens_per_second)) +
  scale_fill_manual(values = c("lmstudio" = "#3498db", "ollama" = "#e74c3c")) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

# Save as PNG
dir.create(here("images"),  showWarnings = FALSE, recursive = TRUE)
image_file <- here("images", "server_box_plot.png")
ggsave(image_file, plot = p1, width = 9, height = 5, dpi = 300)

# Print the speed ratio of LM Studio vs. Ollama
print("Speed ratio: LM Studio (MLX) vs. Ollama (GGUF)")
print(mean(lmstudio_data$tokens_per_second)/mean(ollama_data$tokens_per_second))

# Create box plot with one box for each quantization method
p2 <- ggplot(merged_data_quant_method, aes(x = source, y = tokens_per_second, fill = source)) +
  geom_boxplot(width = 0.6) +
  labs(
    title = "Tokens Per Second by Model Quantization Method",
    x = "Model",
    y = "Tokens Per Second (tokens/sec)"
  ) + 
  ylim(0, max(merged_data_quant_method$tokens_per_second)) +
  scale_fill_manual(values = c("qwen3.5-9b-mlx" = "#3498db", "qwen3.5-9b-gguf" = "#e74c3c")) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

# Save as PNG
dir.create(here("images"),  showWarnings = FALSE, recursive = TRUE)
image_file <- here("images", "quant_method_box_plot.png")
ggsave(image_file, plot = p2, width = 9, height = 5, dpi = 300)

# Print the speed ratio of MLX vs. GGUF with LM Studio
print("Speed ratio: MLX vs. GGUF (both served by LM Studio)")
print(mean(mlx_data$tokens_per_second)/mean(gguf_data$tokens_per_second))
