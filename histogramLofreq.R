#Forma parte de la pipeline de Lofreq
#Imprime el histograma de las frecuencias de las variantes
args=commandArgs(trailingOnly = TRUE)

library(tidyverse)

muestra <- read_tsv(file=args[1], col_types=cols(POS=col_character()))

pdf( paste(args[2],".pdf",sep="") )

ggplot(data=muestra, aes(muestra$`ALLELE FREQUENCY`)) + geom_histogram() + labs(title=args[2], x="Allele frequency", y="count")

dev.off()
