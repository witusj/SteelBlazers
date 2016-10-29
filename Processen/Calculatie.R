# Laad aanvragen
source("Processen/Aanvragen.R")
materiaal <- unique(dfAanvraagCorr$Materiaal)

# Bereken uiterste productiedatum (reserveer 2 dagen expeditie uit)
dfAanvraagCorr <- mutate(dfAanvraagCorr, Productiedatum = Datum + Levertermijn - 3)
dfAanvraagCorr <- dfAanvraagCorr[order(dfAanvraagCorr$Productiedatum),]

# Voeg complexiteit, snijlijn en kosten toe
n <- dim(dfAanvraagCorr)[1]

dfAanvraagCorr$Complexiteit <- sample(1:10, n, replace = TRUE)
dfAanvraagCorr$Snijlijn <- sample(1:10, n, replace = TRUE)
dfAanvraagCorr <- mutate(dfAanvraagCorr, Kosten = Aantal * (Complexiteit + Snijlijn))

# Splits aanvragen naar materiaal
lstAanvragen <- as.list(NULL)

for (d in materiaal) {
  g <- which(materiaal == d)
  lstAanvragen[g] <- list(dfAanvraagCorr[dfAanvraagCorr$Materiaal == d,])
} 

# Groepeer naar aanvraagdatum en materiaal bereken totale kosten
grpMateriaal <- group_by(dfAanvraagCorr, Datum,  Materiaal)
per_datum <- summarise(grpMateriaal, Kosten = sum(Kosten))

# Groepeer naar productiedatum en materiaal en bereken totale kosten
grpMateriaal <- group_by(dfAanvraagCorr, Productiedatum,  Materiaal)
per_proddatum <- summarise(grpMateriaal, Kosten = sum(Kosten))

# Bereken verspilling en aantal platen
standaard <- 500 # Dit zijn de kosten van 1 plaat
per_proddatum <- mutate(per_proddatum, Verspilling = standaard - Kosten %% standaard,
                        VerspillingPerc = round(100* Verspilling / (Kosten + Verspilling)),
                        Platen = (Kosten + Verspilling)/standaard)

lstProductie <- as.list(NULL)

for (m in materiaal) {
  s <- which(materiaal == m)
  lstProductie[s] <- list(per_proddatum[per_proddatum$Materiaal == m,])
}  


# Groepeer naar productiedatum en bereken totale uren
grpProdDatum <- group_by(per_proddatum[,c(1, 6)], Productiedatum)
tot_uren <- summarise(grpProdDatum, Uren = sum(Platen))

# Plot hoeveelheden gesorteerd op aanvraag- en productiedatum
materiaal <- unique(per_datum$Materiaal)

# Bepaal de  range voor beide assen
xrange <- c(min(dfAanvraagCorr$Datum), max(dfAanvraagCorr$Productiedatum))
yrange <- range(per_proddatum$Kosten) 

# Aantal grafieken per rij en kolom
par(mfrow=c(2,length(materiaal)), adj=1)

# Bouw plots

for (i in materiaal) {
  
  k <- which(materiaal == i)
  
  plot(xrange, yrange, type="n",
       ylab="Kosten", sub = paste0("Aanvraagdatum: ",i)) 
  colors <- rainbow(length(materiaal))
  linetype <- c(1:length(materiaal))
  
  orders <- subset(per_datum, Materiaal == i) 
  lines(per_datum$Datum, per_datum$Kosten, type="b", lwd=1.5, lty=linetype[k], col=colors[k]) 
}

# Voeg titels toe 
title("Kosten per aanvraagdatum")


for (i in materiaal) {
  
  k <- which(materiaal == i)
  
  plot(xrange, yrange, type="n",
       ylab="Kosten", sub = paste0("Productiedatum: ",i)) 
  colors <- rainbow(length(materiaal))
  linetype <- c(1:length(materiaal))
  
  orders <- subset(per_proddatum, Materiaal == i) 
  lines(per_proddatum$Productiedatum, per_proddatum$Kosten, type="b", lwd=1.5, lty=linetype[k], col=colors[k]) 
}

# Voeg titels toe 
title("Kosten per productiedatum")