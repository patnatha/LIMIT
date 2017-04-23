library(readr)
library(dplyr)

import_csv <- function(path_to_file){
    dat <- read.delim(path_to_file, sep='|')
    return(tbl_df(dat))
}

demo_info_path="/scratch/leeschro_armis/leeschro/DataDirect/POCglucose_V03/POCglucose_v03 - DemographicInfo.csv"
patient_bday_path="/scratch/leeschro_armis/leeschro/DataDirect/POCglucose_V03/POCglucose_v03 - PatientInfo.csv"
diagnoses_path="/scratch/leeschro_armis/leeschro/DataDirect/POCglucose_V03/POCglucose_v03 - DiagnosesEverything.csv"
lab_values_path="/scratch/leeschro_armis/leeschro/DataDirect/POCglucose_V03/POCglucose_v03 - LabResults.csv"
encouter_all_path="/scratch/leeschro_armis/leeschro/DataDirect/POCglucose_V03/POCglucose_v03 - EncounterAll.csv"
encounter_location_path="/scratch/leeschro_armis/leeschro/DataDirect/POCglucose_V03/POCglucose_v03 - EncounterLocations.csv"

demo_info=import_csv(demo_info_path)
patient_bday=import_csv(patient_bday_path)
diagnoses=import_csv(diagnoses_path)
encounter_all=import_csv(encouter_all_path)
encouter_location=import_csv(encounter_location_path)
lab_values=import_csv(lab_values_path)

