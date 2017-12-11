library("RSQLite")
source("../import_files.R")

#Parse input from command line
library(optparse)
option_list <- list(
    make_option("--input", type="character", default="", help="directory to load data from"),
    make_option("--output", type="character", default="/scratch/leeschro_armis/patnatha/prepared_data/", help="filepath output"),
    make_option("--name", type="character", default="", help="name of this set analysis"),
    make_option("--age", type="character", default="", help="enter range of ages separate by _"),
    make_option("--sex", type="character", default="", help="enter Male|Female|Both"),
    make_option("--race", type="character", default="", help="enter White|Black|All"),
    make_option("--include", type="character", default="", help="groups to include")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
input_dir = args[['input']]

#Calculate the file size
filesize<-system(paste("ls -l ", input_dir, " | awk '{ total += $5 }; END { print total }'", sep=""), ignore.stderr = TRUE, intern = TRUE)
print(paste("Total Filesize: ", round(as.double(filesize) / (1024.0 * 1024.0 * 1024.0), digit=2), " GB", sep=""))

#Parse the input race value
race=tolower(args[['race']])
includeRace=NA
if(race == "" | race == "all"){
    includeRace = NA
    race = NA
} else if(race == "white"){
    includeRace = "C"
} else if(race == "black"){
    includeRace = "AA"
} else {
    print("ERROR: sex is invalid")
    stop()
}

#Parse the input sex value
sex=tolower(args[['sex']])
includeSex=NA
if(sex == "" || sex == "both"){
    includeSex = NA
    sex = NA
} else if (sex == "male"){
    includeSex = "M"
} else if(sex == "female"){
    includeSex = "F"
} else {
    print("ERROR: sex is invalid Male|Female|Both")
    stop()
}
 
#Parse the output directory and create if doesn't exists
output_directory = args[['output']]
if(!dir.exists(output_directory)){
    print("The output directory doesn't exists")
    stop()
}

#Function for converting months to days
convert_month_to_days = function(tTime){
    stTime = tTime * floor(tTime / 12) * 365
    addMon = tTime %% 12
    if(addMon >= 1){
        stTime = stTime + 31
    }
    if(addMon >= 2){
        stTime = stTime + 28
    }
    if(addMon >= 3){
        stTime = stTime + 31
    } 
    if(addMon >= 4){
        stTime = stTime + 30
    } 
    if(addMon >= 5){
        stTime = stTime + 31
    } 
    if(addMon >= 6){
        stTime = stTime + 30
    } 
    if(addMon >= 7){
        stTime = stTime + 31
    }
    if(addMon >= 8){
        stTime = stTime + 31
    } 
    if(addMon >= 9){
        stTime = stTime + 30
    }
    if(addMon >= 10){
        stTime = stTime + 31
    }
    if(addMon >= 11){
        stTime = stTime + 30
    } 
    if(addMon >= 12){
        stTime = stTime + 31
    }
    return(stTime)
}

#Parse out the ageBias
ageBias = c(NA, NA)
age = tolower(args[["age"]])
if(age == "" || age == "adult"){
    #By default get all adults
    age = "adult"
    ageBias = c(20 * 365, 100 * 365)
} else if(age == "all"){
    #If specified all then get all
    ageBias = c(0, 100 * 365)
} else {
    theSplit = strsplit(age, "_")[[1]]
    if(length(theSplit) == 2){
        startTime = theSplit[[1]]
        endTime = theSplit[[2]]

        sTimeUnit = substr(startTime, nchar(startTime), nchar(startTime))
        startTime = as.numeric(substr(startTime, 1, nchar(startTime)-1))
        sTime = NA
        if(sTimeUnit == "y"){
            sTime = startTime * 365
        } else if(sTimeUnit == "m"){
            sTime = convert_month_to_days(startTime)
        } else if(sTimeUnit == "d"){
            sTime = startTime
        } else {
            print("ERROR: Start Time is not Y|M|D")
            stop()
        }

        eTimeUnit = substr(endTime, nchar(endTime), nchar(endTime))
        endTime = as.numeric(substr(endTime, 1, nchar(endTime) - 1))
        eTime = NA
        if(eTimeUnit == "y"){
            eTime = endTime * 365
        } else if(eTimeUnit == "m"){
            eTime = convert_month_to_days(endTime)
        } else if(eTimeUnit == "d"){
            eTime = endTime
        } else {
            print("ERROR: End Time is not Y|M|D")
            stop()
        }

        ageBias = c(sTime, eTime)
    }
    else{
        print("ERROR: age format [start]_[end] in decimals of years")
        stop()
    }
}

#Parse the include statement
toInclude = tolower(args[["include"]])
if(toInclude != ""){
    if(toInclude != "inpatient" &
       toInclude != "outpatient" &
       toInclude != "never_inpatient" &
       toInclude != "outpatient_and_never_inpatient"){
        toInclude == NA
    }
} else {
    toInclude = NA
}

#Parse the name from input if exists
if(args[["name"]] == ""){
    #Build the filename
    theBasename = basename(input_dir)

    #Add teh age range if it is in there
    if(!is.na(age)){
        theBasename = paste(theBasename, age, sep="_")
    }

    #Add the inclusion sex
    if(!is.na(sex)){
        theBasename = paste(theBasename, "_", sex, sep="")
    }

    #Add the inclusion race
    if(!is.na(race)){
        theBasename = paste(theBasename, "_", race, sep="")
    }

    #Add the inclusion groups
    if(!is.na(toInclude)){
        theBasename = paste(theBasename, "_", toInclude, sep="")
    }

    output_filename = gsub("//", "/", paste(output_directory, theBasename, sep="/"))
} else {
    output_filename = gsub("//", "/", paste(output_directory, args[['name']], sep="/"))
}
output_filename = paste(output_filename, '.Rdata', sep="")
print(output_filename)
if(file.exists(output_filename)){
    print(paste("The output filename already exists: ", output_filename, sep=""))
    stop()
}

#Load up the csv files
print("Loading Patient B-Day")
patient_bday = import_patient_bday(input_dir)

#Load up the patient demo graphic info and combine with patient bday info
print("Loading Patient Demographics")
patient_demo = import_demo_info(input_dir)

print("Combine Patient D-Day & Demographics")
patient_bday = inner_join(patient_bday, patient_demo %>% select(PatientID, GenderCode, GenderName, RaceCode, RaceName), by="PatientID")
remove(patient_demo)

#Select on Male or Female
if(!is.na(includeSex)){
    print("Filter Patient Info Based on Sex")
    patient_bday = patient_bday %>% filter(GenderCode == includeSex)
}

#Select on Include Race
if(!is.na(includeRace)){
    print("Filter Patient Info Based on Race")
    patient_bday = patient_bday %>% filter(RaceCode == includeRace)
}

#Error stmt
if(nrow(patient_bday) == 0){
    print("Patient Bday is Empty")
    stop()
}

#Build the lab values dataset
print("Loading Lab Values")
lab_values = import_lab_values(input_dir)
print("LV: Calculate Time-Offest")
labValuesDplyr = inner_join(lab_values, patient_bday, by="PatientID")
remove(lab_values)
labValuesDplyr = labValuesDplyr %>% mutate(
                                        timeOffset = as.numeric(
                                            as.Date(COLLECTION_DATE) - as.Date(DOB)
                                        )
                                    )

#Filter labValues based on age bias
if(!is.na(ageBias[[1]])){
    labValuesDplyr = labValuesDplyr %>% filter(timeOffset >= ageBias[[1]] & timeOffset < ageBias[[2]])
}

#Exclude all the lab values that are not consistent with a grouping
encountersAll = NA
if(!is.na(toInclude)){
    preFilLen = nrow(labValuesDplyr)
    if(toInclude == "inpatient"){
        encountersAll = import_encounter_all(labValuesDplyr$PatientID)
        print("LV: Extract Inpatients")
        labValuesDplyr = inner_join(labValuesDplyr, 
                                    encountersAll %>% filter(PatientClassCode == "Inpatient"))
    } else if(toInclude == "outpatient"){
        encountersAll = import_encounter_all(labValuesDplyr$PatientID)
        print("LV: Extract Outpatients")
        labValuesDplyr = inner_join(labValuesDplyr, 
                                    encountersAll %>% filter(PatientClassCode == "Outpatient"))
    } else if(toInclude == "never_inpatient" | toInclude == "outpatient_and_never_inpatient"){
        print("LV: Extract Never Inpatients")
    
        #Join labvalues and list of patients who have been inpatient
        p1 = get_encounters_never_inpatient()
        labValuesDplyr = left_join(labValuesDplyr, p1, by="PatientID")
        remove(p1)

        #Exclude labvalues that occured after atheir first inpatient admission
        labValuesDplyr = labValuesDplyr %>% filter(is.null(FirstInpatient) | is.na(FirstInpatient) | FirstInpatient == "" | as.Date(COLLECTION_DATE) < as.Date(FirstInpatient))

        #Make sure that also the current lab value is not in the ED
        if(toInclude == "outpatient_and_never_inpatient"){
            encountersAll = import_encounter_all(labValuesDplyr$PatientID)
            labValuesDplyr = inner_join(labValuesDplyr,
                                        encountersAll %>% filter(PatientClassCode == "Outpatient"))
        }
    }

    print(paste("Extracted:", preFilLen, '=>', nrow(labValuesDplyr), sep=" "))
}

print("LV: Select columns for output")
labValuesDplyr = rename(labValuesDplyr, pid = PatientID)
labValuesDplyr = rename(labValuesDplyr, l_val = VALUE)
labValues<-labValuesDplyr %>% select(pid, l_val, timeOffset, EncounterID) %>% as.data.frame()
resultCode = unique(labValuesDplyr$RESULT_CODE)
orderCode = unique(labValuesDplyr$ORDER_CODE)

remove(labValuesDplyr)

print("Loading Other Labs")
allLabs = import_labs_all(unique(labValues$pid))
otherLabsDplyr = inner_join(allLabs, patient_bday, by="PatientID")

print("Other Labs: Filter results on not similar to analyte")
otherLabsDplyr = otherLabsDplyr %>% filter(HILONORMAL_FLAG != "") 
otherLabsDplyr = otherLabsDplyr %>% filter(HILONORMAL_FLAG != "N")
otherLabsDplyr = otherLabsDplyr %>% filter(!ORDER_CODE %in% orderCode)
otherLabsDplyr = otherLabsDplyr %>% filter(!RESULT_CODE %in% resultCode)


print("Other Labs: Build columns necessary for algorithm")
otherLabsDplyr = otherLabsDplyr %>%
                    mutate(timeOffset =
                        as.numeric(as.Date(COLLECTION_DATE)
                        -
                        as.Date(DOB)))
otherLabsDplyr = rename(otherLabsDplyr, pid = PatientID)
otherLabsDplyr = otherLabsDplyr %>% mutate(icd = paste(HILONORMAL_FLAG, "_", RESULT_CODE, sep=""))
otherLabsDplyr = otherLabsDplyr %>% mutate(icd_name = paste(HILONORMAL_COMMENT, "_", RESULT_NAME, sep=""))

print("Other Labs: Select columns for output")
otherLabs<-otherLabsDplyr %>% select(pid, icd, icd_name, timeOffset, ACCESSION_NUMBER)
remove(otherLabsDplyr)

print("Loading Diagnoses")
diagnoses = import_diagnoses(input_dir)
diagnosis_process = inner_join(diagnoses, patient_bday, by="PatientID")
remove(diagnoses)

print("DX: Combine with encounters")
if(is.na(encountersAll)){ encountersAll = import_encounter_all(diagnosis_process$PatientID) }
icdValuesDplyr = inner_join(diagnosis_process, encountersAll %>% filter(AdmitDate != ""))
remove(encountersAll)

print("DX: Calculate Time-Offset")
icdValuesDplyr = rename(icdValuesDplyr, pid = PatientID)
icdValuesDplyr = rename(icdValuesDplyr, icd = TermCodeMapped)
icdValuesDplyr = rename(icdValuesDplyr, icd_name = TermNameMapped)
icdValuesDplyr = icdValuesDplyr %>%
                    mutate(timeOffset =
                        as.numeric(as.Date(AdmitDate)
                        -
                        as.Date(DOB)))

print("Dx: Select columns for output")
icdValues<-icdValuesDplyr %>% select(pid, icd, icd_name, timeOffset, EncounterID, Lexicon) %>% as.data.frame()
remove(icdValuesDplyr)

print("Loading Medications")
med_admin = import_med_admin(input_dir)
medsAdminDyplyr = med_admin %>% filter(MedicationStatus == "Given")
remove(med_admin)

print("MED: Calculate Time-Offset")
medsAdminDyplyr = inner_join(medsAdminDyplyr, patient_bday, by="PatientID")
medsAdminDyplyr = rename(medsAdminDyplyr, pid = PatientID)
medsAdminDyplyr = rename(medsAdminDyplyr, icd = MedicationTermID)
medsAdminDyplyr = rename(medsAdminDyplyr, icd_name = MedicationName)
medsAdminDyplyr = medsAdminDyplyr %>% 
                    mutate(timeOffset = 
                        as.numeric(as.Date(DoseStartTime) 
                        - 
                        as.Date(DOB)))

print("MED: Select columns for output")
medValues<-medsAdminDyplyr %>% select(pid, icd, icd_name, timeOffset, EncounterID) %>% as.data.frame()
remove(medsAdminDyplyr)

print("SAVING RESULTS")
save(labValues, icdValues, medValues, otherLabs, file=output_filename)

