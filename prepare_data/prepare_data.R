source("../import_files.R")

#Parse input from command line
library(optparse)
option_list <- list(
    make_option("--input", type="character", default=NULL, help="directory to load data from"),
    make_option("--output", type="character", default="/scratch/leeschro_armis/patnatha/prepared_data/", help="filepath output"),
    make_option("--name", type="character", default=NULL, help="name of this set analysis"),
    make_option("--age", type="character", default=NULL, help="enter range of ages separate by _"),
    make_option("--include", type="character", default=NULL, help="groups to include")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
input_dir = args[['input']]

#Calculate the file size
filesize<-system(paste("ls -l ", input_dir, " | awk '{ total += $5 }; END { print total }'", sep=""), ignore.stderr = TRUE, intern = TRUE)
x<-paste("Total Filesize: ", round(as.double(filesize) / (1024.0 * 1024.0 * 1024.0), digit=2), " GB", sep="")
print(x)

#Parse the output directory and create if doesn't exists
output_directory = args[['output']]
if(!dir.exists(output_directory)){
    print("The output directory doesn't exists")
    stop()
}

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

if(is.null(args[["age"]]) || is.na(args[["age"]]) || args[["age"]] == "adult"){
    #By default get all adults
    args[["age"]] = "adult"
    ageBias = c(18 * 365, 100 * 365)
} else if(args[["age"]] == "all"){
    #If specified all then get all
    ageBias = c(0, 100 * 365)
} else {
    theSplit = strsplit(args[['age']], "_")[[1]]
    if(length(theSplit) == 2){
        startTime = theSplit[[1]]
        endTime = theSplit[[2]]

        sTimeUnit = substr(startTime, nchar(startTime), nchar(startTime))
        startTime = as.numeric(substr(startTime, 1, nchar(startTime)-1))
        sTime = NA
        if(sTimeUnit == "Y"){
            sTime = startTime * 365
        } else if(sTimeUnit == "M"){
            sTime = convert_month_to_days(startTime)
        } else if(sTimeUnit == "D"){
            sTime = startTime
        } else {
            print("ERROR: Start Time is not Y|M|D")
            stop()
        }

        eTimeUnit = substr(endTime, nchar(endTime), nchar(endTime))
        endTime = as.numeric(substr(endTime, 1, nchar(endTime) - 1))
        eTime = NA
        if(eTimeUnit == "Y"){
            eTime = endTime * 365
        } else if(eTimeUnit == "M"){
            eTime = convert_month_to_days(endTime)
        } else if(eTimeUnit == "D"){
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

toInclude = NULL
if(!is.null(args[["include"]])){
    toInclude = args[["include"]]
    if(toInclude != "inpatient" &
       toInclude != "outpatient" &
       toInclude != "never_inpatient" &
       toInclude != "outpatient_and_never_inpatient"){
        toInclude == NULL
    }
}    

#Parse the name from input if exists
if(is.null(args[["name"]])){
    #Build the filename
    theBasename = basename(input_dir)

    #Add teh age range if it is in there
    if(!is.null(args[["age"]])){
        theBasename = paste(theBasename, args[["age"]], sep="_")
    }

    #Add the inclusion groups
    if(!is.null(toInclude)){
        theBasename = paste(theBasename, "_", toInclude, sep="")
    }

    output_filename = gsub("//", "/", paste(output_directory, theBasename, sep="/"))
} else {
    output_filename = gsub("//", "/", paste(output_directory, args[['name']], sep="/"))
}
output_filename = paste(output_filename, '.Rdata', sep="")
print(output_filename)
if(file.exists(output_filename)){
    print("The output filename already exists")
    stop()
}

#Load up the csv files
print("Loading Patient B-Day")
patient_bday = import_patient_bday(input_dir)

#Load up all the encouters for the given pids
print("Loading Patient Encounter's")
encountersAll = import_encounter_all(patient_bday$PatientID)

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
if(!is.null(ageBias)){
    # Only get the lab values of patients older than 19 years 
    labValuesDplyr = labValuesDplyr %>% filter(timeOffset < ageBias[[1]] & timeOffset < ageBias[[2]])
}

#Exclude all the lab values that are not consistent with a grouping
if(!is.null(toInclude)){
    preFilLen = nrow(labValuesDplyr)
    if(toInclude == "inpatient"){
        print("LV: Extract Inpatients")
        labValuesDplyr = inner_join(labValuesDplyr, 
                                    encountersAll %>% filter(PatientClassCode == "Inpatient"))
    } else if(toInclude == "outpatient"){
        print("LV: Extract Outpatients")
        labValuesDplyr = inner_join(labValuesDplyr, 
                                    encountersAll %>% filter(PatientClassCode == "Outpatient"))
    } else if(toInclude == "never_inpatient" | toInclude == "outpatient_and_never_inpatient"){
        print("LV: Extract Never Inpatients")
    
        #Get list of PIDs who have been inpatient
        library("RSQLite")
        con = dbConnect(drv=SQLite(), dbname="/scratch/leeschro_armis/patnatha/EncountersAll/EncountersAll.db")
        p1 = dbGetQuery(con,'SELECT PatientID, FirstInpatient, InpatientCnt FROM ever_inpatient WHERE InpatientCnt > 0')
        dbDisconnect(con)

        #Join labvalues and list of patients who have been inpatient
        labValuesDplyr = left_join(labValuesDplyr, p1, by="PatientID")
        remove(p1)

        #Exclude labvalues that occured after atheir first inpatient admission
        labValuesDplyr = labValuesDplyr %>% filter(is.null(FirstInpatient) | as.Date(COLLECTION_DATE) < as.Date(FirstInpatient))

        #Make sure that also the current lab value is not in the ED
        if(toInclude == "outpatient_and_never_inpatient"){
            labValuesDplyr = inner_join(labValuesDplyr,
                                        encountersAll %>% filter(PatientClassCode == "Outpatient"))
        }
    }

    print(paste("Extracted:", preFilLen, '=>', nrow(labValuesDplyr), sep=" "))
}

#Get only the columns we want
print("LV: Select columns for output")
labValuesDplyr = rename(labValuesDplyr, pid = PatientID)
labValuesDplyr = rename(labValuesDplyr, l_val = VALUE)
labValues<-labValuesDplyr %>% select(pid, l_val, timeOffset, EncounterID) %>% as.data.frame()
remove(labValuesDplyr)

#Get the diagnosis and pair with PtID to build the timeOffset
print("Loading Diagnoses")
diagnoses = import_diagnoses(input_dir)
diagnosis_process = inner_join(diagnoses, patient_bday, by="PatientID")
remove(diagnoses)

print("DX: Combine with encounters")
encounter_earliest = encountersAll %>% filter(AdmitDate != "")
remove(encountersAll)
icdValuesDplyr = inner_join(diagnosis_process, encounter_earliest)
remove(encounter_earliest)


#Get the icd code assignment as an offset value
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

#Get Medications that were administered
print("Loading Medications")
med_admin = import_med_admin(input_dir)
medsAdminDyplyr = med_admin %>% filter(MedicationStatus == "Given")
remove(med_admin)

#Get the administration date as an offset value
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

#Save the massaged data
print("SAVING RESULTS")
save(labValues, icdValues, medValues, file=output_filename)

