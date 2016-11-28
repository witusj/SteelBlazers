library(gsheet)
library(googleVis)
library(dplyr)
source("Rollen/Rollen.R")
source("Processen/DiagCalculatie.R")

frmJaarrekening <- gsheet2tbl(
  'https://docs.google.com/spreadsheets/d/1KB9PlhP7K4ghBpZsdzUBiQgsUw97SZVnP4hRiZT927M/pub?output=csv'
)
colnames(frmJaarrekening) <- NULL
frmJaarrekening[,c(2,4)] <- format(frmJaarrekening[,c(2,4)], decimal.mark=",",big.mark=".",small.mark=".")
frmJaarrekening[is.na(frmJaarrekening)] <-NULL
tblJaarrekening <- htmlTable(frmJaarrekening,
                             cgroup=c("Activa", "Passiva"),
                             n.cgroup=c(2,2),
                             caption="Balans per 31.12.2015 (bedragen in EUR)",
                             align="lrlr",
                             rnames=FALSE,
                             css.cell = c("padding-left: .5em; padding-right: .8em;",
                                          "padding-left: 1.8em; padding-right: .8em;",
                                          "padding-left: .5em; padding-right: .8em;",
                                          "padding-left: 1.8em; padding-right: .8em;"),
                             col.columns = c("none", "#F1F0FA"),
                             total=TRUE)
tblJaarrekening <- gsub("NA</td>", "", tblJaarrekening)