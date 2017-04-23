source("import_csv.R")
library(plyr)

#Get the diagnosis and pair with PtID to build the timeOffset
diagnosis_process=inner_join(diagnoses, patient_bday)
diagnosis_process=inner_join(diagnosis_process, encounter_all, by="EncounterID")

#Get the columns that we need
icdValuesDplyr = select(diagnosis_process, one_of(c("PatientID.x","TermCodeMapped","TermNameMapped", "DOB", "EncounterAgeInYears")))
icdValuesDplyr = rename(icdValuesDplyr, c("PatientID.x" = "PatientID"))
icdValuesDplyr = rename(icdValuesDplyr, c("EncounterAgeInYears" = ""))


#Create the empty data frame
icdValues<-data.frame(timeOffset=as.Date(),
                      icd=as.character(),
                      pid=as.character()
                     )

labValues<-data.frame(timeOffset=as.Date(),
                      l_val=as.character(),
                      pid=as.character()
                     )


