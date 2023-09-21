#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

#print(args)

# Verify that the necessary arguments have been specified.
if (length(args) != 1) {
  stop("Use program: output.txt.\nCheck input fasta file")
} else {
  print(args)
}


##library to use________________________________________________________________
packages <- c("ggplot2")

# Check if the packages are installed

for (package in packages) {
  if (requireNamespace(package, quietly = TRUE)) {
    # El paquete está instalado, cargarlo con library()
    library(package, character.only = TRUE)
  } else {
    # The package is not installed, install it and load it with library().
    install.packages(package)
    library(package, character.only = TRUE)
  }
}

#setwd("/home/usuario/PERL/NLfifty/")

##Read our data_________________________________________________________________

contig <- read.table(args[1], #"output.txt
                   sep = "\t",
                   stringsAsFactors = T,
                   header = T)

# NEED CONDITIONS

##Graphics section______________________________________________________________

##Histogram_____________________________________________________________________

##Histogram length______________________________________________________________

n_contig <- length(contig$Contig.id)
n_write <- paste("Total nº of contigs = ", n_contig)
n_binwidth <- round(mean(contig$Contig.length))
#n_maxx <- max(contig$Contig.length)

lengthContig <- ggplot(contig, aes(x= Contig.length, fill= Contig.length)) + 
  geom_histogram(binwidth = n_binwidth, fill="gray21", color = "gray1", alpha=0.9, position = "identity")+
  #geom_density(aes(y = ..count..*1500),adjust = 2, col = "black", fill = "gray1", alpha= 0.2)+
  theme(legend.position="none",
        plot.title = element_text(size=11), 
        panel.background = element_rect(fill = "white",
                                        colour ="grey50")) +
  labs(y = n_write , x = "Total length of contig (pb)")

# Make test Kolmogórov-Smirnov
test_ks <- ks.test(contig$Contig.length, pnorm, mean(contig$Contig.length), sd(contig$Contig.length))
print(test_ks)

# Save plot in file
ggsave(filename = "contig_plot.pdf", plot = lengthContig, width = 8.27, height = 8.27)

# show success message on command line
cat("\nSuccessfully saved the file", filename, "\n")