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
packages <- c("ggplot2","gridExtra")

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

n_contig <- length(contig$length)
n_write <- paste("nº total contigs = ", n_contig)
n_binwidth <- round(mean(contig$length))
#n_maxx <- max(contig$Contig.length)

lengthContig <- ggplot(contig, aes(y = length, x = "variable", fill = "variable")) +
  geom_violin(position = position_dodge(width = 0.9), alpha=.4) +
  geom_boxplot(width = .2, alpha = .6, show.legend = FALSE) +
  #geom_point(position = position_jitterdodge(jitter.width = 0.2, dodge.width = 0.9), alpha = 0.6, size = 1) +  # Ajusta la posición de los puntos
  scale_fill_brewer(palette = "Set1", name = "Tipo") +
  theme_minimal()+
  theme(legend.position = "none")+
  labs(x = n_write , y = "Length of contig (pb)")

gcContig <- ggplot(contig, aes(y = GC, x = "variable", fill = "variable")) +
  geom_violin(position = position_dodge(width = 0.9), alpha=.4) +
  geom_boxplot(width = .2, alpha = .6, show.legend = FALSE) +
  #geom_point(position = position_jitterdodge(jitter.width = 0.2, dodge.width = 0.9), alpha = 0.6, size = 1) +  # Ajusta la posición de los puntos
  scale_fill_brewer(palette = "Set1", name = "Tipo") +
  theme_minimal()+
  theme(legend.position = "none")+
  labs(x = n_write , y = "GC of contig (pb)")

#contig_filtered <- subset(contig, length < 100000)

 lengthContig <- ggplot(contig_filtered, aes(x= length, fill= length)) + 
   geom_histogram(binwidth = n_binwidth/100000, fill="gray21", color = "gray1", alpha=0.9, position = "identity")+
   #geom_density(aes(y = ..count..*1500),adjust = 2, col = "black", fill = "gray1", alpha= 0.2)+
   theme(legend.position="none",
         plot.title = element_text(size=11), 
         panel.background = element_rect(fill = "white",
                                         colour ="grey50")) +
   labs(y = n_write , x = "Largo de contigs (mpb)")+
   scale_x_continuous(labels = scales::comma_format(scale = 1e-6))
 
# Make test Kolmogórov-Smirnov
cat("\n\tLength distribution:\n")
test_ks <- ks.test(contig$length, pnorm, mean(contig$length), sd(contig$length))
print(test_ks)
cat("\n\tGC distribution:\n")
test_ks_gc <- ks.test(contig$GC, pnorm, mean(contig$GC), sd(contig$GC))
print(test_ks_gc)

gcLength<- grid.arrange(lengthContig, gcContig, nrow=1, ncol=2)

# Save plot in file
ggsave(filename = "contig_plot.pdf", plot = gcLength, width = 8.27, height = 8.27)

# show success message on command line
cat("\nSuccessfully saved the file", "contig_plot.pdf", "\n")