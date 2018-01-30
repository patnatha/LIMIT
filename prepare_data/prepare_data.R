library("RSQLite")
library("stringr")
source("../import_files.R")

#Parse input from command line
library(optparse)
option_list <- list(
    make_option("--input", type="character", default=NA, help="directory to load data from"),
    make_option("--output", type="character", default="/scratch/leeschro_armis/patnatha/prepared_data/", help="filepath output"),
    make_option("--name", type="character", default="", help="name of this set analysis"),
    make_option("--age", type="character", default=NA, help="enter range of ages separate by _"),
    make_option("--sex", type="character", default=NA, help="enter Male|Female|Both"),
    make_option("--race", type="character", default=NA, help="enter White|Black|All"),
    make_option("--include", type="character", default=NA, help="groups to include")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
input_val = args[['input']]

#Parse the input race value
race=tolower(args[['race']])
includeRace=NA
if(is.na(race) || race == "" || race == "all"){
    includeRace = NA
    race = "all"
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
if(is.na(sex) || sex == "" || sex == "both"){
    includeSex = NA
    sex = "both"
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
    print("ERROR: The output directory doesn't exists")
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
if(is.na(age) || age == "" || age == "adult"){
    age = "adult"
    ageBias = c(20 * 365, 100 * 365)
} else if(age == "all"){
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
if(!is.na(toInclude) &
   toInclude != "inpatient" &
   toInclude != "outpatient" &
   toInclude != "never_inpatient" &
   toInclude != "outpatient_and_never_inpatient"){
    print("ERROR: include_group is invalid")
    stop() 
}

#Parse the name from input if exists
if(args[["name"]] == ""){
    #Build the filename
    theBasename = basename(str_replace(input_val, ",", "_"))

    #Add the inclusion race
    if(!is.na(race)){
        theBasename = paste(theBasename, "_", race, sep="")
    }

    #Add the inclusion sex
    if(!is.na(sex)){
        theBasename = paste(theBasename, "_", sex, sep="")
    }

    #Add teh age range if it is in there
    if(!is.na(age)){
        theBasename = paste(theBasename, age, sep="_")
    }

    #Add the inclusion groups
    if(!is.na(toInclude)){
        theBasename = paste(theBasename, "_", toInclude, sep="")
    }

    output_filename = gsub("//", "/", paste(output_directory, theBasename, sep="/"))
} else {
    output_filename = gsub("//", "/", paste(output_directory, args[['name']], sep="/"))
}

#Check the output file for existence
output_filename = paste(output_filename, '.Rdata', sep="")
print(output_filename)
if(file.exists(output_filename)){
    print(paste("ERROR: The output filename already exists: ", output_filename, sep=""))
    stop()
}

#Parse the input_vals
if(!is.na(input_val)){
    input_val = strsplit(input_val, ",")[[1]]
} else {
    print("ERROR: no input analyte")
    stop()
}

#Load up the lab values data set
print("Loading Lab Values")
startDate = unclass(as.Date("2013-01-01"))
endDate = unclass(as.Date("2018-01-01"))
labValues = import_lab_values(input_val, startDate, endDate)

#Load up the Patient Info
print("Loading Patient B-Day")
patient_bday = import_patient_bday(labValues$PatientID)

#Load up the patient demo graphic info 
print("Loading Patient Demographics")
patient_demo = import_demo_info(labValues$PatientID)

print("Combine Patient D-Day & Demographics")
patient_bday = inner_join(patient_bday, patient_demo %>% select(PatientID, GenderCode, GenderName, RaceCode, RaceName), by="PatientID")
remove(patient_demo)

#Select on Male or Female
if(!is.na(includeSex)){
    print(paste("Filter Patient Info Based on Sex: ", includeSex, sep=""))
    patient_bday = patient_bday %>% filter(GenderCode == includeSex)
}

#Select on Include Race
if(!is.na(includeRace)){
    print(paste("Filter Patient Info Based on Race: ", includeRace, sep=""))
    patient_bday = patient_bday %>% filter(RaceCode == includeRace)
}

#Error stmt
if(nrow(patient_bday) == 0){
    print("Patient B-Day is Empty")
    stop()
}

print("LV: Calculate Time-Offest")
labValues = inner_join(labValues, patient_bday, by="PatientID")
labValues = labValues %>% mutate(timeOffset = as.numeric(
                                 as.Date(COLLECTION_DATE) - as.Date(DOB)))

#Filter labValues based on age bias
if(!is.na(ageBias[[1]])){
    print(paste("LV: Extract age range: ", ageBias[[1]], " - ", ageBias[[2]], " days", sep=""))
    labValues = labValues %>% filter(timeOffset >= ageBias[[1]] & timeOffset < ageBias[[2]])
}

#Exclude all the lab values that are not consistent with a grouping
encountersAll = NA
if(!is.na(toInclude)){
    #Down sampling code
    pidSampleMax = 300000
    uniquePIDs = unique(labValues$PatientID)
    if(length(uniquePIDs) > pidSampleMax){
        print(paste("LV: Down Sample PIDs, ", length(uniquePIDs), " => ", format(pidSampleMax, scientific=FALSE), sep=""))
        randomlySelectedPIDs = sample(uniquePIDs, pidSampleMax)
        labValues = labValues %>% filter(PatientID %in% randomlySelectedPIDs)
        remove(randomlySelectedPIDs)
    }
    remove(uniquePIDs)

    #Get count of lab values before inclusion groups
    preFilLen = nrow(labValues)

    if(toInclude == "inpatient"){
        encountersAll = import_encounter_all(labValues$PatientID)
        print("LV: Include Inpatients")
        labValues = inner_join(labValues, 
                               encountersAll %>% select("PatientID", "EncounterID", "PatientClassCode") %>% filter(PatientClassCode == "Inpatient"), by=c("PatientID", "EncounterID")) %>% select (-c(PatientClassCode)) 
    } else if(toInclude == "outpatient"){
        encountersAll = import_encounter_all(labValues$PatientID)
        print("LV: Include Outpatients")
        labValues = inner_join(labValues, 
                               encountersAll %>% select("PatientID", "EncounterID", "PatientClassCode") %>% filter(PatientClassCode == "Outpatient"), by=c("PatientID", "EncounterID")) %>% select (-c(PatientClassCode)) 
    } else if(toInclude == "never_inpatient" | toInclude == "outpatient_and_never_inpatient"){
        print("LV: Exclude Ever Inpatient")
    
        #Join labvalues and list of patients who have been inpatient
        p1 = get_encounters_never_inpatient()
        labValues = left_join(labValues, p1, by="PatientID")
        remove(p1)

        #Exclude labvalues that occured after their first inpatient admission
        labValues = labValues %>% filter(is.null(FirstInpatient) | is.na(FirstInpatient) | FirstInpatient == "" | as.Date(COLLECTION_DATE) < as.Date(FirstInpatient)) %>% select (-c(FirstInpatient, InpatientCnt))

        #Make sure that also the current lab value is not in the ED
        if(toInclude == "outpatient_and_never_inpatient"){
            encountersAll = import_encounter_all(labValues$PatientID)
            print("LV: Include Outpatients")
            labValues = inner_join(labValues,
                                   encountersAll %>% select("PatientID", "EncounterID", "PatientClassCode") %>% filter(PatientClassCode == "Outpatient"), by=c("PatientID", "EncounterID")) %>% select (-c(PatientClassCode))
        }
    }

    print(paste("Extracted Labs", preFilLen, '=>', nrow(labValues), ":", toInclude, sep=" "))
}

print("LV: Select columns for output")
save(labValues, file="temp.Rdata")
glimpse(labValues)
labValues = labValues %>% rename( pid = PatientID)
labValues = labValues %>% rename(l_val = VALUE)
labValues = labValues %>% select(pid, l_val, timeOffset, EncounterID)

print("Loading Diagnoses")
icdValues = import_diagnoses(unique(labValues$pid))
icdValues = inner_join(icdValues, patient_bday, by="PatientID")

print("DX: Combine with encounters")
if(typeof(encountersAll) != "list"){ encountersAll = import_encounter_all(icdValues$PatientID) }
icdValues = inner_join(icdValues, encountersAll %>% filter(AdmitDate != ""), by=c("PatientID", "EncounterID"))
remove(encountersAll)

print("DX: Calculate Time-Offset")
icdValues = icdValues %>% rename(pid = PatientID)
icdValues = icdValues %>% rename(icd = TermCodeMapped)
icdValues = icdValues %>% rename(icd_name = TermNameMapped)
icdValues = icdValues %>% mutate(timeOffset =
                                 as.numeric(as.Date(AdmitDate)
                                    -
                                 as.Date(DOB)))

print("DX: Select columns for output")
icdValues = icdValues %>% select(pid, icd, icd_name, timeOffset, EncounterID, Lexicon)

print("Loading Other Labs")
otherLabs = import_other_abnormal_labs(unique(labValues$pid))
otherLabs = inner_join(otherLabs, patient_bday, by="PatientID")

print("Loading Results Codes: find similar result_codes to analyte")
similarResultCodes = get_similar_lab_codes(input_val)
if('HGB' %in% input_val || 'HGBN' %in% input_val){
    similarResultCodes = c(similarResultCodes, "HCT", "HCRT", "RBC")
    similarResultCodes = unique(similarResultCodes)
}

print("Other Labs: exclude similar result codes")
otherLabs = otherLabs %>% filter(!RESULT_CODE %in% similarResultCodes)

print("Other Labs: Calculate Time-Offset")
otherLabs = otherLabs %>% mutate(timeOffset = as.numeric(
                                 as.Date(COLLECTION_DATE) - as.Date(DOB)))
glimpse(otherLabs)
otherLabs = otherLabs %>% rename(pid = PatientID)
otherLabs = otherLabs %>% mutate(icd = paste(HILONORMAL_FLAG, "_", RESULT_CODE, sep=""))
otherLabs = otherLabs %>% mutate(icd_name = paste(HILONORMAL_COMMENT, "_", RESULT_NAME, sep=""))

print("Other Labs: Select columns for output")
otherLabs<-otherLabs %>% select(pid, icd, icd_name, timeOffset)

print("Loading Medications")
medValues = import_med_admin(unique(labValues$pid))
medValues = inner_join(medValues, patient_bday, by="PatientID")

print("MED: Calculate Time-Offset")
medValues = medValues %>% mutate(timeOffset = as.numeric(
                                 as.Date(DoseStartTime) - as.Date(DOB)))
medValues = medValues %>% rename(pid = PatientID)
medValues = medValues %>% rename(icd = MedicationTermID)
medValues = medValues %>% rename(icd_name = MedicationName)

print("MED: Select columns for output")
medValues = medValues %>% select(pid, icd, icd_name, timeOffset, EncounterID)

print("SAVING RESULTS")
parameters<-1:1
attr(parameters, "resultCode") = input_val
attr(parameters, "resultStart") = as.Date(as.POSIXlt(startDate * 86400, origin="1970-01-01"))
attr(parameters, "resultEnd") = as.Date(as.POSIXlt(endDate * 86400, origin="1970-01-01"))
attr(parameters, "race") = race
attr(parameters, "age") = ageBias
attr(parameters, "sex") = sex
attr(parameters, "group") = toInclude
attr(parameters, "similarResultCodes") = similarResultCodes
save(parameters, labValues, icdValues, medValues, otherLabs, file=output_filename)

