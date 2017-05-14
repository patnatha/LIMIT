# Load up additional information
source('import_csv.R')
glucose_vals=import_csv('/scratch/leeschro_armis/patnatha/glucose_3_month/')
patient_bday=glucose_vals$patient_bday
diagnoses=glucose_vals$diagnoses
encounter_location=glucose_vals$encounter_location

# Create the diff lab value and then convert to Dplyr
load('/scratch/leeschro_armis/patnatha/glucose_3_month/paired_glucoses.Rdata')
results$value_diff=results$one_value-results$two_value
labValues<-data.frame(PatientID=results$pid, one_ascen=results$one_accession, two_ascen=results$two_accession, VALUE=results$value_diff, COLLECTION_DATE=results$one_collect)
labValuesDplyr<-tbl_df(labValues)

# Get the labValues
labValuesDplyr = inner_join(labValuesDplyr, patient_bday, by="PatientID")
labValuesDplyr = rename(labValuesDplyr, pid = PatientID)
labValuesDplyr = rename(labValuesDplyr, l_val = VALUE)
labValuesDplyr = labValuesDplyr %>% mutate(timeOffset = as.numeric(as.Date(COLLECTION_DATE) - as.Date(DOB)))
labValues<-labValuesDplyr %>% as.data.frame()

# Get ICD codes
diagnosis_process=inner_join(diagnoses, patient_bday, by="PatientID")
encounter_earliest=encounter_location %>% group_by(EncounterID) %>% summarise(StartDate = min(as.Date(StartDate)))
diagnosis_process=inner_join(diagnosis_process, encounter_earliest, by="EncounterID")
icdValuesDplyr = rename(icdValuesDplyr, pid = PatientID)
icdValuesDplyr = rename(icdValuesDplyr, icd = TermCodeMapped)
icdValuesDplyr = icdValuesDplyr %>% mutate(timeOffset = as.numeric(as.Date(StartDate) - as.Date(DOB)))
icdValues<-icdValuesDplyr %>% as.data.frame()

save(labValues, icdValues, file='/scratch/leeschro_armis/patnatha/prepared_data/prepared_paired_glucoses.Rdata')

