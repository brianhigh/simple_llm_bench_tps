# R script to merge datasets and create box plot by server

# Load required libraries
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(here)

# Read the two datasets
lmstudio_data <- read_csv(here("data", "lmstudio_llm_bench.csv"), show_col_types = FALSE)
ollama_data <- read_csv(here("data", "ollama_llm_bench.csv"), show_col_types = FALSE)

# Add a source column to distinguish the datasets
lmstudio_data$source <- "lmstudio"
ollama_data$source <- "ollama"

# Merge the datasets by combining them
merged_data <- bind_rows(lmstudio_data, ollama_data)

# Create box plot with one box for each server
p <- ggplot(merged_data, aes(x = source, y = tokens_per_second, fill = source)) +
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
image_file <- here("images", "box_plot.png")
ggsave(image_file, plot = p, width = 5, height = 9, dpi = 300)

# Print to console for verification
print(p)

# Print the speed ratio of LLM Studio vs. Ollama
print(mean(lmstudio_data$tokens_per_second)/mean(ollama_data$tokens_per_second))
