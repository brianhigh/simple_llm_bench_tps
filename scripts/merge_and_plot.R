# R script to merge datasets and create bar plots

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

# Create bar plot with one bar for each server
aggregated_data_server <- merged_data_server |>
  group_by(source) %>% summarise(tokens_per_second = mean(tokens_per_second, na.rm = TRUE))
p1 <- ggplot(aggregated_data_server, aes(x = source, y = tokens_per_second, fill = source)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Speed Test: LM Studio (MLX) vs. Ollama (GGUF)",
    subtitle = "Using Qwen3.5 9B on a 16 GB M1 Pro MacBook Pro",
    x = "Source",
    y = "Tokens Per Second (tokens/sec)",
    fill = "Source"
  ) + 
  scale_fill_manual(values = c("lmstudio" = "#3498db", "ollama" = "#e74c3c")) +
  theme_minimal() +
  theme(
    plot.subtitle = element_text(size = 10) # Change font size here
  )

# Save as PNG
dir.create(here("images"),  showWarnings = FALSE, recursive = TRUE)
image_file <- here("images", "server_bar_plot.png")
ggsave(image_file, plot = p1, width = 5, height = 4, dpi = 300)

# Print the speed ratio of LM Studio vs. Ollama
print("Speed ratio: LM Studio (MLX) vs. Ollama (GGUF)")
print(mean(lmstudio_data$tokens_per_second)/mean(ollama_data$tokens_per_second))

# Create bar plot with one bar for each quantization method
aggregated_data_quant_method <- merged_data_quant_method |>
  group_by(source) %>% summarise(tokens_per_second = mean(tokens_per_second, na.rm = TRUE)) |>
  mutate(source = ifelse(grepl('mlx', source), 'MLX', 'GGUF'))
p2 <- ggplot(aggregated_data_quant_method, aes(x = source, y = tokens_per_second, fill = source)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Quantization Speed Test: MLX vs. GGUF",
    subtitle = "Using Qwen3.5 9B from LM Studio on a 16 GB M1 Pro MacBook Pro",
    x = "Source",
    y = "Tokens Per Second (tokens/sec)",
    fill = "Source"
  ) + 
  scale_fill_manual(values = c("MLX" = "#3498db", "GGUF" = "#e74c3c")) +
  theme_minimal() +
  theme(
    plot.subtitle = element_text(size = 10) # Change font size here
  )

# Save as PNG
dir.create(here("images"),  showWarnings = FALSE, recursive = TRUE)
image_file <- here("images", "quant_method_bar_plot.png")
ggsave(image_file, plot = p2, width = 5, height = 4, dpi = 300)

# Print the speed ratio of MLX vs. GGUF with LM Studio
print("Speed ratio: MLX vs. GGUF (both served by LM Studio)")
print(mean(mlx_data$tokens_per_second)/mean(gguf_data$tokens_per_second))


