# Load up additional information
source('import_csv.R')
glucose_vals=import_csv('/scratch/leeschro_armis/patnatha/glucose_3_month/')
patient_bday=glucose_vals$patient_bday
diagnoses=glucose_vals$diagnoses
encounter_location=glucose_vals$encounter_location
med_admin=glucose_vals$med_admin

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
labValues<-labValuesDplyr %>% select(pid, l_val, timeOffset) %>% as.data.frame()

# Get ICD codes
diagnosis_process=inner_join(diagnoses, patient_bday, by="PatientID")
encounter_earliest=encounter_location %>% group_by(EncounterID) %>% summarise(StartDate = min(as.Date(StartDate)))
icdValuesDplyr = inner_join(diagnosis_process, encounter_earliest, by="EncounterID")
icdValuesDplyr = rename(icdValuesDplyr, pid = PatientID)
icdValuesDplyr = rename(icdValuesDplyr, icd = TermCodeMapped)
icdValuesDplyr = rename(icdValuesDplyr, icd_name = TermNameMapped)
icdValuesDplyr = icdValuesDplyr %>% mutate(timeOffset = as.numeric(as.Date(StartDate) - as.Date(DOB)))
icdValues<-icdValuesDplyr %>% select(pid, icd, timeOffset, EncounterID) %>% as.data.frame()

#Get Medications that were administered
medsAdminDyplyr = med_admin %>% filter(MedicationStatus == "Given")
medsAdminDyplyr = inner_join(medsAdminDyplyr, patient_bday, by="PatientID")
medsAdminDyplyr = rename(medsAdminDyplyr, pid = PatientID)
medsAdminDyplyr = rename(medsAdminDyplyr, icd = MedicationTermID)
medsAdminDyplyr = rename(medsAdminDyplyr, icd_name = MedicationName)
medsAdminDyplyr = medsAdminDyplyr %>% mutate(timeOffset = as.numeric(as.Date(DoseStartTime) - as.Date(DOB)))
medValues<-medsAdminDyplyr %>% select(pid, icd, timeOffset, icd_name, EncounterID) %>% as.data.frame()

#Save the results
save(labValues, icdValues, medValues, file='/scratch/leeschro_armis/patnatha/prepared_data/prepared_paired_glucoses.Rdata')

