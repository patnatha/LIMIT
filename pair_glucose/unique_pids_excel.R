#Load up the results array
source('glucose_paths.R')
load(paired_glucoses_path)

uniquePids = data.frame("PatientID" = unique(results$pid))

library(WriteXLS)
WriteXLS(uniquePids,  ExcelFileName = paste(dirname(paired_glucoses_path), "/uniquePids.xlsx", sep=""), SheetNames = NULL, row.names = FALSE, col.names = TRUE)

