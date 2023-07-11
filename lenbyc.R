##library to use________________________________________________________________
library(tidyverse)
library(ggplot2)


##We set directory______________________________________________________________
setwd("/home/usuario/acca/data_base/")

##Read our data_________________________________________________________________

contig <- read.table("lentgh_of_contig_acca.txt",
                   sep = "\t",
                   stringsAsFactors = T,
                   header = T)


##Graphics section______________________________________________________________

##Histogram_____________________________________________________________________

##Histogram length RT candiadtes athila/tat_____________________________________

n_contig <- length(contig$Contig.id)
n_write <- paste("nº total contig = ", n_contig)

candidate_RT_length <- ggplot(contig, aes(x= Contig.length, fill= Contig.length)) + 
  geom_histogram(binwidth = 100000, fill="gray21", color = "gray1", alpha=0.9, position = "identity")+
  #geom_density(aes(y = ..count..*1500),adjust = 2, col = "black", fill = "gray1", alpha= 0.2)+
  theme(legend.position="none",
        plot.title = element_text(size=11), 
        panel.background = element_rect(fill = "white",
                                        colour ="grey50")) +
  labs(y = n_write , x = "Largo total de contig (pb)") 

length(candidate_total_rt$Length)
mean(candidate_total_rt$Length)##There are many trash sequence!!!!!!!
sd(candidate_total_rt$Length)

ks.test(candidate_total_rt$Length, pnorm, mean(candidate_total_rt$Length), sd(candidate_total_rt$Length))


