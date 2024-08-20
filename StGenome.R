#!/usr/bin/env Rscript

# Load necessary libraries
library(Biostrings)
library(ggplot2)
library(dplyr)

# Function to calculate genome statistics
calculate_genome_statistics <- function(fasta_files) {
  
  results <- data.frame(
    file_name = character(),
    genome_length = numeric(),
    num_contigs = numeric(),
    contig_length = numeric(),
    gc_genome = numeric(),
    gc_contig = numeric(),
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
    
    # Calculate the total genome length
    genome_length <- sum(width(sequences))
    
    # Calculate the number of contigs
    num_contigs <- length(sequences)
    
    # Calculate the length of each contig
    contig_lengths <- width(sequences)
    
    # Calculate the GC content of the genome
    gc_genome <- sum(letterFrequency(sequences, letters = c("G", "C"))) / genome_length * 100
    
    # Calculate the GC content of each contig
    gc_contig <- letterFrequency(sequences, letters = c("G", "C")) / contig_lengths * 100
    
    # Sort the contigs by size in descending order
    sorted_contig_lengths <- sort(contig_lengths, decreasing = TRUE)
    
    # Function to calculate N50, L50, etc.
    calculate_N_L_metrics <- function(sorted_contig_lengths, total_genome_length, thresholds) {
      cumulative_length <- 0
      metrics <- data.frame(n = numeric(), l = numeric(), stringsAsFactors = FALSE)
      
      for (threshold in thresholds) {
        target_length <- total_genome_length * (threshold / 100)
        
        for (i in seq_along(sorted_contig_lengths)) {
          cumulative_length <- cumulative_length + sorted_contig_lengths[i]
          if (cumulative_length >= target_length) {
            metrics <- rbind(metrics, data.frame(n = sorted_contig_lengths[i], l = i))
            break
          }
        }
      }
      
      return(metrics)
    }
    
    # Define thresholds for calculations
    thresholds <- c(50, 60, 70, 90)
    
    # Calculate metrics
    metrics <- calculate_N_L_metrics(sorted_contig_lengths, genome_length, thresholds)
    
    # Append the results to the dataframe
    results <- rbind(results, data.frame(
      file_name = file,
      genome_length = genome_length,
      num_contigs = num_contigs,
      contig_length = mean(contig_lengths),
      gc_genome = gc_genome,
      gc_contig = mean(gc_contig),
      n50 = metrics$n[1],
      l50 = metrics$l[1],
      n60 = metrics$n[2],
      l60 = metrics$l[2],
      n70 = metrics$n[3],
      l70 = metrics$l[3],
      n90 = metrics$n[4],
      l90 = metrics$l[4],
      stringsAsFactors = FALSE
    ))
  }
  
  return(results)
}

# Read command-line arguments
args <- commandArgs(trailingOnly = TRUE)

# Execute the function with the provided FASTA files
results <- calculate_genome_statistics(args)

# Get the directory of the first FASTA file
file_directory <- dirname(args[1])

# Save the results to a CSV file in the same directory as the FASTA file
result_file <- file.path(file_directory, "genome_statistics.csv")
write.csv(results, file = result_file, row.names = FALSE)

# Function to save plots in the same directory as the FASTA file
save_plot <- function(plot, file_name) {
  full_file_path <- file.path(file_directory, file_name)
  ggsave(full_file_path, plot = plot)
}

# Plot genome length
genome_length_plot <- ggplot(results, aes(x = file_name, y = genome_length)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ggtitle("Genome Length")
save_plot(genome_length_plot, "genome_length.png")

# Additional plots for other metrics can be added similarly
