# Sodium, serum/plasma

library(DBI)
library(RMySQL)

drv = dbDriver("MySQL")
con = dbConnect(drv, user = "spoole", dbname = "stride5", host = "ncbolabs-db1.stanford.edu", password = "******")

query = "SELECT lid, proc, description, component, pid, age, 
timeoffset, ord_num, result_flag, ref_low, ref_high, ref_unit, result_inrange, 
ref_norm FROM lab WHERE proc = \"LABNA\";"

data = dbGetQuery(con, query)
save(data, file = "LABNAdata.Rdata")

# Two different units: mEq/L and mmol/L but conversion factor is 1.0

CheckForNoVisitData = function(patient) {
  query = sprintf("SELECT * FROM stride5.visit WHERE pid = %s", as.numeric(patient))
  data = dbGetQuery(con, query)  
  if (length(data[1, ]) == 0) {
    return(TRUE)
  } 
  return(FALSE)
}

CheckForNoDrugData = function(patient) {
  query = sprintf("SELECT ingr_set_id FROM stride5.prescription WHERE pid = %s", as.numeric(patient))
  codes = dbGetQuery(con, query)  
  if (length(codes) == 0) {
    return(TRUE)
  }
  return(FALSE)
}

# Filtering out patients with no visit data
allPIDs = unique(data$pid)
noVisitPIDs = unlist(allPIDs[sapply(allPIDs, CheckForNoVisitData)])
noVisitIndices = which(data$pid %in% noVisitPIDs)
data = data[-noVisitIndices, ]
save(data, file = 'LABNAVisitChecked.Rdata')
