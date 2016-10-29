library(rvest)
library(tidyr)
library(dplyr)
library(googleVis)

op <- options(gvis.plot.tag='chart')

# Haal data op van CBS, extraheer de juiste tabel en verwijder onnodige variabelen
cbsData <- read_html("http://statline.cbs.nl/Statweb/publication/?DM=SLNL&PA=81810NED&D1=0&D2=29&D3=170-172,174-180,182-184,187-189,191-196&HDR=G2&STB=G1,T&VW=T")
nodes <- html_nodes(cbsData, "table")
tables <- html_table(nodes, fill = TRUE, dec = ",")
cbsTabel <- tables[7][[1]]
cbsTabel <- cbsTabel[1,c(-1:-5)]

# Maak de eerste waarde basis = 100
newBase <- cbsTabel[1,1]
cbsTabel[1,] <- cbsTabel[1,]*100/newBase

# Creeer een data frame met het juiste type variabelen
cbsTabel <- t(cbsTabel)
cbsTabel <- data_frame(Maand = rownames(cbsTabel), Index = as.vector(cbsTabel[,1]))
cbsTabel <- filter(cbsTabel, !grepl('kwartaal', Maand))
cbsTabel$Maand <- gsub("\\*", "", cbsTabel$Maand)
cbsTabel <- data.frame(apply(cbsTabel, 2, unclass), stringsAsFactors = FALSE)
cbsTabel$Index <- as.numeric(cbsTabel$Index)

# Bouw de plot
cbsLine <- gvisLineChart(cbsTabel, options=list(width=900, height=400, title="Ontwikkeling metaalproductie", legend = 'none'))