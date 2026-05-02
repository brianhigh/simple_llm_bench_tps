# R script to merge datasets and create bar plots

# Load necessary packages
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(readr, dplyr, tidyr, purrr, ggplot2, here)

# Setup folder paths
data_dir <- here("data")
images_dir <- here("images")
dir.create(images_dir,  showWarnings = FALSE, recursive = TRUE)

# Read the datasets
lmstudio_data <-
  read_csv(file.path(data_dir, "lmstudio_llm_bench.csv"),
           show_col_types = FALSE)
ollama_data <-
  read_csv(file.path(data_dir, "ollama_llm_bench.csv"),
           show_col_types = FALSE)
mlx_data <-
  read_csv(file.path(data_dir, "qwen35-9b-mlx_llm_bench.csv"),
           show_col_types = FALSE)
gguf_data <-
  read_csv(file.path(data_dir, "qwen35-9b-gguf_llm_bench.csv"),
           show_col_types = FALSE)
qwen_data_files <-
  list("qwen35-9b-mlx", "qwen3-14b-mlx", "qwen3-8b-mlx",
       "qwen3-4b-instruct-2507-mlx", "qwen25-coder-14b-instruct-mlx",
       "qwen25-7b-instruct-mlx")
qwen_data_files <- paste0(qwen_data_files, "-4bit_llm_bench.csv")
qwen_data <- bind_rows(map_df(qwen_data_files, ~ {
  read_csv(file.path(data_dir, .x), show_col_types = FALSE)
}))

# Add a source column to distinguish the datasets
lmstudio_data$source <- "LM Studio"
ollama_data$source <- "Ollama"
mlx_data$source <- "MLX"
gguf_data$source <- "GGUF"
qwen_data$source <- qwen_data$model

# Merge the datasets by combining them
merged_data_server <- bind_rows(lmstudio_data, ollama_data)
merged_data_quant_method <- bind_rows(mlx_data, gguf_data)

# Create bar plot with one bar for each server
aggregated_data_server <- merged_data_server |> group_by(source) |>
  summarise(tokens_per_second = mean(tokens_per_second, na.rm = TRUE))
p1 <- ggplot(aggregated_data_server,
             aes(x = reorder(source, -tokens_per_second),
                 y = tokens_per_second, fill = source)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = tokens_per_second), vjust = 1.5, color = "white") +
  labs(
    title = "Speed Test: LM Studio (MLX) vs. Ollama (GGUF)",
    subtitle = "Using Qwen3.5 9B on a 16 GB M1 Pro MacBook Pro",
    x = "Server",
    y = "Tokens Per Second (tokens/sec)",
    fill = "Source"
  ) +
  scale_fill_manual(values = c("LM Studio" = "#3498db", "Ollama" = "#e74c3c")) +
  theme_minimal() +
  theme(
    plot.subtitle = element_text(size = 10),
    legend.position = "none"
  )

# Save as PNG
server_image_file <- file.path(images_dir, "server_bar_plot.png")
ggsave(server_image_file, plot = p1, width = 5, height = 4, dpi = 300)

# Print the speed ratio of LM Studio vs. Ollama
print("Speed ratio: LM Studio (MLX) vs. Ollama (GGUF)")
print(mean(lmstudio_data$tokens_per_second) /
        mean(ollama_data$tokens_per_second))

# Create bar plot with one bar for each quantization method
aggregated_data_quant_method <- merged_data_quant_method |> group_by(source) |>
  summarise(tokens_per_second = mean(tokens_per_second, na.rm = TRUE))
p2 <- ggplot(aggregated_data_quant_method,
             aes(x = reorder(source, -tokens_per_second),
                 y = tokens_per_second, fill = source)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = tokens_per_second), vjust = 1.5, color = "white") +
  labs(
    title = "Quantization Speed Test: MLX vs. GGUF",
    subtitle = "Using Qwen3.5 9B with LM Studio on a 16 GB M1 Pro MacBook Pro",
    x = "Quantization Method",
    y = "Tokens Per Second (tokens/sec)",
    fill = "Source"
  ) +
  scale_fill_manual(values = c("MLX" = "#3498db", "GGUF" = "#e74c3c")) +
  theme_minimal() +
  theme(
    plot.subtitle = element_text(size = 10),
    legend.position = "none"
  )

# Save as PNG
quant_method_image_file <- file.path(images_dir, "quant_method_bar_plot.png")
ggsave(quant_method_image_file, plot = p2, width = 5, height = 4, dpi = 300)

# Print the speed ratio of MLX vs. GGUF with LM Studio
print("Speed ratio: MLX vs. GGUF (both served by LM Studio)")
print(mean(mlx_data$tokens_per_second) /
        mean(gguf_data$tokens_per_second))

# Create bar plot with one bar for each server
aggregated_data_qwen <- qwen_data |> group_by(source) |>
  summarise(tokens_per_second = mean(tokens_per_second, na.rm = TRUE))
p3 <- ggplot(aggregated_data_qwen,
             aes(x = reorder(source, tokens_per_second),
                 y = tokens_per_second)) +
  geom_bar(stat = "identity", fill = "#3498db") +
  geom_text(aes(label = tokens_per_second), hjust = 1.2, color = "white") +
  labs(
    title = "Speed Test: Qwen Models (MLX, 4-bit)",
    subtitle = "Using Qwen3.5 9B with LM Studio on a 16 GB M1 Pro MacBook Pro",
    x = "Model",
    y = "Tokens Per Second (tokens/sec)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 7.2),
    plot.subtitle = element_text(hjust = 1.44, size = 10),
    legend.position = "none"
  ) + coord_flip()

# Save as PNG
qwen_image_file <- file.path(images_dir, "qwen_bar_plot.png")
ggsave(qwen_image_file, plot = p3, width = 5, height = 4, dpi = 300)