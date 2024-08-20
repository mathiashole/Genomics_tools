#!/usr/bin/env Rscript

# Load necessary libraries
library(Biostrings)
library(ggplot2)
library(dplyr)
library(tidyr)

# Function to calculate genome statistics
calculate_genome_statistics <- function(fasta_files) {
  
  results <- data.frame(
    file_name = character(),
    genome_length = numeric(),
    num_contigs = numeric(),
    avg_contig_length = numeric(),
    gc_genome = numeric(),
    avg_gc_contig = numeric(),
    n50 = numeric(),
    l50 = numeric(),
    n60 = numeric(),
    l60 = numeric(),
    n70 = numeric(),
    l70 = numeric(),
    n90 = numeric(),
    l90 = numeric(),
    stringsAsFactors = FALSE
  )
  
  for (file in fasta_files) {
    # Read the FASTA file
    sequences <- readDNAStringSet(file)
    
    # Calculate basic statistics
    genome_length <- sum(width(sequences))
    num_contigs <- length(sequences)
    contig_lengths <- width(sequences)
    gc_counts <- letterFrequency(sequences, letters = c("G", "C"))
    gc_genome <- sum(gc_counts) / genome_length * 100
    avg_gc_contig <- mean(gc_counts / contig_lengths * 100)
    
    # Sort the contigs by size in descending order
    sorted_contig_lengths <- sort(contig_lengths, decreasing = TRUE)
    
    # Function to calculate N and L metrics
    calculate_N_L_metrics <- function(sorted_lengths, total_length, thresholds) {
      cumulative_length <- cumsum(sorted_lengths)
      metrics <- sapply(thresholds, function(threshold) {
        idx <- which(cumulative_length >= total_length * (threshold / 100))[1]
        c(n = sorted_lengths[idx], l = idx)
      })
      return(metrics)
    }
    
    # Define thresholds and calculate metrics
    thresholds <- c(50, 60, 70, 90)
    metrics <- calculate_N_L_metrics(sorted_contig_lengths, genome_length, thresholds)
    
    # Append the results to the dataframe
    results <- rbind(results, data.frame(
      file_name = file,
      genome_length = genome_length,
      num_contigs = num_contigs,
      avg_contig_length = mean(contig_lengths),
      gc_genome = gc_genome,
      avg_gc_contig = avg_gc_contig,
      n50 = metrics["n", 1],
      l50 = metrics["l", 1],
      n60 = metrics["n", 2],
      l60 = metrics["l", 2],
      n70 = metrics["n", 3],
      l70 = metrics["l", 3],
      n90 = metrics["n", 4],
      l90 = metrics["l", 4],
      stringsAsFactors = FALSE
    ))
  }
  
  return(results)
}

# Function to save plots in the output directory
save_plot <- function(plot, file_name, output_dir) {
  full_file_path <- file.path(output_dir, file_name)
  ggsave(full_file_path, plot = plot)
}

# Read command-line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("No FASTA files provided. Please provide one or more FASTA files as input.")
}

# Execute the function with the provided FASTA files
results <- calculate_genome_statistics(args)

# Get the directory of the first FASTA file
file_directory <- dirname(args[1])
output_directory <- file.path(file_directory, "genome_stats_output")
dir.create(output_directory, showWarnings = FALSE)

# Save the results to a CSV file in the output directory
result_file <- file.path(output_directory, "genome_statistics.csv")
write.csv(results, file = result_file, row.names = FALSE)

# Plot genome length
genome_length_plot <- ggplot(results, aes(x = file_name, y = genome_length)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("Genome Length")
save_plot(genome_length_plot, "genome_length.png", output_directory)

# Plot contig length distribution
contig_distribution_plot <- ggplot(results, aes(x = file_name, y = avg_contig_length)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("Average Contig Length")
save_plot(contig_distribution_plot, "contig_distribution.png", output_directory)

