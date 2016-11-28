library(gsheet)
library(dplyr)

# Klantgegevens
frmKlanten <- gsheet2tbl(
  'https://docs.google.com/spreadsheets/d/1N6lnNNyd8PrE_DpTQIWFuc8aPmsqkTkjjDHcRK5vTd0/pub?output=csv'
)

# Genereer verdeling variabelen
set.seed(100)
varDate <- seq(as.Date("2016/1/1"), as.Date("2016/12/31"), "days")
boolTek <- c(rep(0,50), rep(1,950))                                   # Verdeling correcte technische tekeningen
boolMat <- as.factor(c(rep("NA",100), rep("RVS 10mm",1000), rep("RVS 7mm",500), # Verdeling materiaal
             rep("Staal 7mm",600)))
boolTerm <- c(rep(5,200), rep(10,60), rep(30,10))                     # Verdeling termijn

# Genereer per klant random aantal aanvragen
dfAanvraagRaw <- NULL

for(k in frmKlanten$Naam) {
  
  
  n <- sample(10:100,1)                                                 # Aantal bestellingen
  
  aanvDatum <- sample(varDate, n, replace = FALSE, prob = NULL)         # Sample n data
  aanvAantal <- round(abs(rnorm(n,100,50)))+5                           # Sample aantallen uit normale verdeling
  aanvTekening <- sample(boolTek, n) == 1                               # Sample technische tekeningen
  aanvMateriaal <- sample(boolMat, n)                                   # Sample materiaal
  aanvTermijn <- sample(boolTerm, n)                                    # Sample levertermijn
  
  dfAanvraagRaw <- rbind(dfAanvraagRaw, data.frame(Datum = aanvDatum, Klant = k,
                                             Technische.tekening = aanvTekening,
                                             Aantal = aanvAantal, Materiaal = aanvMateriaal,
                                             Levertermijn = aanvTermijn))
  
}

# Corrigeer fouten en voeg kosten (tijd) toe
aanvFt <- filter(dfAanvraagRaw, Technische.tekening == FALSE | Materiaal == "NA")
aanvFt$Technische.tekening <- TRUE
aanvMateriaalFt <- filter(aanvFt, Materiaal == "NA")
q <- dim(aanvMateriaalFt)[1]
aanvFt$Materiaal[aanvFt$Materiaal == "NA"] <- sample(boolMat[boolMat != "NA"], q)

m <- rep(1:4, dim(dfAanvraagRaw)[1]/4)
p <- dim(aanvFt)[1]
vertraging <- sample(m, p)
aanvFt$Datum <- transmute(aanvFt, Datum = Datum + vertraging)
aanvFt$Datum <- aanvFt$Datum[[1]]

dfAanvraag <- rbind(dfAanvraagRaw, aanvFt)

# Sorteer op datum en filter op correcte aanvragen
dfAanvraag <- dfAanvraag[order(dfAanvraag$Datum),]
dfAanvraagCorr <- filter(dfAanvraag, Technische.tekening == TRUE, Materiaal != "NA")