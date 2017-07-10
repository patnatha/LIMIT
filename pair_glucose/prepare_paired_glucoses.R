# Load up paths for processing
source('glucose_paths.R')

# Load up additional information
source('../import_files.R')
patient_bday=import_patient_bday(input_dir)

# Create the diff lab value and then convert to Dplyr
load(paste(inputDir, 'paired_glucoses.Rdata', sep=""))
results$value_diff=results$one_value-results$two_value
labValues<-data.frame(PatientID=results$pid, 
                        one_ascen=results$one_accession, 
                        two_ascen=results$two_accession, 
                        VALUE=results$value_diff, 
                        COLLECTION_DATE=results$one_collect)
labValuesDplyr<-tbl_df(labValues)

# Get the labValues
labValuesDplyr = inner_join(labValuesDplyr, patient_bday, by="PatientID")
labValuesDplyr = rename(labValuesDplyr, pid = PatientID)
labValuesDplyr = rename(labValuesDplyr, l_val = VALUE)
labValuesDplyr = labValuesDplyr %>% 
                    mutate(timeOffset =
                        as.numeric(as.Date(COLLECTION_DATE))
                        - 
                        as.numeric(as.Date(DOB)))
labValues<-labValuesDplyr %>% select(pid, l_val, timeOffset, COLLECTION_DATE) %>% as.data.frame()

# Get ICD codes
diagnoses = import_diagnoses(input_dir)
diagnosis_process=inner_join(diagnoses, patient_bday, by="PatientID")
remove(diagnoses)
encounter_location=import_encounter_location(input_dir)
encounter_earliest = encounter_location %>% 
                        group_by(EncounterID) %>% 
                        summarise(StartDate = min(as.Date(StartDate)))
remove(encounter_location)
icdValuesDplyr = inner_join(diagnosis_process, encounter_earliest, by="EncounterID")
icdValuesDplyr = rename(icdValuesDplyr, pid = PatientID)
icdValuesDplyr = rename(icdValuesDplyr, icd = TermCodeMapped)
icdValuesDplyr = rename(icdValuesDplyr, icd_name = TermNameMapped)
icdValuesDplyr = icdValuesDplyr %>% 
                    mutate(timeOffset = 
                        as.numeric(as.Date(StartDate) 
                        - 
                        as.Date(DOB)))
icdValues<-icdValuesDplyr %>% select(pid, icd, timeOffset, EncounterID) %>% as.data.frame()

#Get Medications that were administered
med_admin = import_med_admin(input_dir)
medsAdminDyplyr = med_admin %>% filter(MedicationStatus == "Given")
remove(med_admin)
medsAdminDyplyr = inner_join(medsAdminDyplyr, patient_bday, by="PatientID")
medsAdminDyplyr = rename(medsAdminDyplyr, pid = PatientID)
medsAdminDyplyr = rename(medsAdminDyplyr, icd = MedicationTermID)
medsAdminDyplyr = rename(medsAdminDyplyr, icd_name = MedicationName)
medsAdminDyplyr = medsAdminDyplyr %>% mutate(timeOffset = as.numeric(as.Date(DoseStartTime) - as.Date(DOB)))
medValues<-medsAdminDyplyr %>% select(pid, icd, timeOffset, icd_name, EncounterID) %>% as.data.frame()

#Save the results
save(labValues, icdValues, medValues, file=prepare_paired_glucoses_path)

