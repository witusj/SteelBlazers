library(gsheet)
library(dplyr)
library(googleVis)

frmRollen <- gsheet2tbl(
  'https://docs.google.com/spreadsheets/d/1KD2S-_BkP-9hYqjSYurRVEWK7fT_13K0w79VE4tKiko/pub?gid=0&single=true&output=csv'
)

frmRollen$Totale.Kosten <- frmRollen$Aantal.FTEs * frmRollen$Kosten.FTE
colnames(frmRollen) <- c("Rol","Aantal FTEs", "Kosten per FTE", "Totale Kosten")

tblRollen <- gvisTable(frmRollen, 
                   formats=list(`Kosten per FTE`="#,###", `Totale Kosten`="#,###"))
