library("RSQLite")
library("stringr")
source("../import_files.R")

#Parse input from command line
library(optparse)
option_list <- list(
    make_option("--input", type="character", default=NA, help="directory to load data from"),
    make_option("--start", type="character", default="2013-01-01", help="start date"),
    make_option("--end", type="character", default="2018-01-01", help="end date"),
    make_option("--output", type="character", default="/scratch/leeschro_armis/patnatha/prepared_data/", help="filepath output"),
    make_option("--name", type="character", default="", help="name of this set analysis"),
    make_option("--age", type="character", default=NA, help="enter range of ages separate by _"),
    make_option("--sex", type="character", default=NA, help="enter Male|Female|Both"),
    make_option("--race", type="character", default=NA, help="enter White|Black|All"),
    make_option("--include", type="character", default=NA, help="groups to include")
)

prepare_parse_args <- function(){
    parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
    args <- parse_args(parser)

    input_val = args[['input']]
    input_val = str_replace(input_val, "\\?", "\\ ")

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
        theBasename = basename(str_replace(str_replace(input_val, ",", "_"),"\\ ", "_"))

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
    print(paste("Output File: ", output_filename, sep=""))
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

    #PArse the start date
    startDate = NA
    if(!is.na(args[['start']]) && !is.null(args[['start']])){
        startDate = as.Date(args[['start']], optional = TRUE)
        if(is.na(startDate)){
            print("ERROR: Start Date is invalid")
            stop()
        } else {
            startDate = unclass(startDate)
        }
    } else {
        print("ERROR: Start Date is invalid")
        stop()
    }

    #Parse the end date
    endDate = NA
    if(!is.na(args[['end']]) && !is.null(args[['start']])){
        endDate = as.Date(args[['end']], optional = TRUE)
        if(is.na(endDate)){
            print("ERROR: End Date is invalid")
            stop()
        } else {
            endDate = unclass(endDate)
        }
    } else {
        print("ERROR: End Date is invalid")
        stop()
    }

    parsedCmds<-1:1
    attr(parsedCmds, "input") = input_val
    attr(parsedCmds, "output") = output_directory
    attr(parsedCmds, "start") = startDate
    attr(parsedCmds, "end") = endDate
    attr(parsedCmds, "name") = output_filename
    attr(parsedCmds, "age") = ageBias
    attr(parsedCmds, "sex") = includeSex
    attr(parsedCmds, "race") = includeRace
    attr(parsedCmds, "include") = toInclude
    return(parsedCmds)
}

appendEncounters <- function(curEncList, newList){
    if(typeof(curEncList) == "list"){
        uniqueEncsToQuery = setdiff(unique(newList$EncounterID), unique(curEncList$EncounterID))
        if(length(uniqueEncsToQuery) > 0){
            tempEncounters = import_encounter_encid(uniqueEncsToQuery)
            curEncList = union(curEncList, tempEncounters)
            remove(tempEncounters)
        }
        remove(uniqueEncsToQuery)
    } else {
        curEncList = import_encounter_all(unique(newList$PatientID))
    }
    return(curEncList)
}

excludeValuesEncType <- function(listType, incGrp){
    if(!is.na(toInclude)){
        if(toInclude == "outpatient" || toInclude == "outpatient_and_never_inpatient"){
            listType = listType %>% filter(PatientClassCode == "Outpatient")
        }
    }
    return(listType)
}


#labValues = import_lab_values(input_val, startDate, endDate)
#print("Loading Patient B-Day")
#patient_bday = import_patient_bday(labValues$PatientID)

#Filter the lab results based on partition information
process_lab_values <- function(labValues, patient_bday, parsedCmds){
    input_val = attr(parsedCmds, "input") 
    ageBias = attr(parsedCmds, "age")
    includeSex = attr(parsedCmds, "sex") 
    includeRace = attr(parsedCmds, "race")
    toInclude = attr(parsedCmds, "include")

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

    encountersAll = NA
    if(!is.na(toInclude)){
        #Get count of lab values before inclusion groups
        preFilLen = nrow(labValues)

        if(toInclude == "inpatient"){
            encountersAll = appendEncounters(encountersAll, labValues)
            print("LV: Include Inpatients")
            labValues = inner_join(labValues, 
                                   encountersAll %>% select("PatientID", "EncounterID", "PatientClassCode") %>% filter(PatientClassCode == "Inpatient"), by=c("PatientID", "EncounterID")) %>% select (-c(PatientClassCode)) 
        } else if(toInclude == "outpatient"){
            encountersAll = appendEncounters(encountersAll, labValues)
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
                encountersAll = appendEncounters(encountersAll, labValues)
                print("LV: Include Outpatients")
                labValues = inner_join(labValues,
                                       encountersAll %>% select("PatientID", "EncounterID", "PatientClassCode") %>% filter(PatientClassCode == "Outpatient"), by=c("PatientID", "EncounterID")) %>% select (-c(PatientClassCode))
            }
        }

        print(paste("Extracted Labs", preFilLen, '=>', nrow(labValues), ":", toInclude, sep=" "))
    }

    returnVariable<-1:2
    attr(returnVariable, "labValues") = labValues
    attr(returnVariable, "encountersAll") = encountersAll
    return(returnVariable)
}

prepare_diagnoses <- function(labValues, patient_bday, encountersAll, toInclude){
    print("Loading Diagnoses")
    icdValues = import_diagnoses(unique(labValues$pid))
    icdValues = inner_join(icdValues, patient_bday, by="PatientID")

    print("DX: Combine with encounters")
    encountersAll = appendEncounters(encountersAll, icdValues)
    icdValues = inner_join(icdValues, encountersAll %>% filter(AdmitDate != ""), by=c("PatientID", "EncounterID"))
    icdValues = excludeValuesEncType(icdValues, toInclude)

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
    return(icdValues)
}

prepare_other_labs <- function(labValues, patient_bday, encountersAll, toInclude, input_val){
    print("Loading Other Labs")
    otherLabs = import_other_abnormal_labs(unique(labValues$pid))
    otherLabs = inner_join(otherLabs, patient_bday, by="PatientID")

    print("Other Labs: Combine with encounters")
    encountersAll = appendEncounters(encountersAll, otherLabs)
    otherLabs = inner_join(otherLabs, encountersAll %>% filter(AdmitDate != ""), by=c("PatientID", "EncounterID"))
    otherLabs = excludeValuesEncType(otherLabs, toInclude)

    print("Loading Results Codes: find similar result_codes to analyte")
    similarResultCodes = get_similar_lab_codes(input_val)
    if('HGB' %in% input_val || 'HGBN' %in% input_val){
        hctSimilarResultCodes = get_similar_lab_codes(c("HCT"))
        similarResultCodes = c(similarResultCodes, hctSimilarResultCodes)
        remove(hctSimilarResultCodes)
    } else if('CREAT' %in% input_val){
        egfrSimilarResultCodes = get_similar_lab_codes(c("EGFR"))
        similarResultCodes = c(similarResultCodes, egfrSimilarResultCodes)
        remove(egfrSimilarResultCodes)
    } else if('ICAL' %in% input_val){
        calSimilarResultCodes = get_similar_lab_codes(c("CAL"))
        similarResultCodes = c(similarResultCodes, calSimilarResultCodes)
        remove(calSimilarResultCodes)
    }
    similarResultCodes = unique(similarResultCodes)

    print("Other Labs: exclude similar result codes")
    otherLabs = otherLabs %>% filter(!RESULT_CODE %in% similarResultCodes)

    print("Other Labs: Calculate Time-Offset")
    otherLabs = otherLabs %>% mutate(timeOffset = as.numeric(
                                     as.Date(COLLECTION_DATE) - as.Date(DOB)))
    otherLabs = otherLabs %>% rename(pid = PatientID)
    otherLabs = otherLabs %>% mutate(icd = paste(HILONORMAL_FLAG, "_", RESULT_CODE, sep=""))
    otherLabs = otherLabs %>% mutate(icd_name = paste(HILONORMAL_COMMENT, "_", RESULT_NAME, sep=""))

    print("Other Labs: Select columns for output")
    otherLabs<-otherLabs %>% select(pid, icd, icd_name, timeOffset, EncounterID)
    return(otherLabs)
}

prepare_medications <- function(labValues, patient_bday, encountersAll, toInclude){
    print("Loading Medications")
    medValues = import_med_admin(unique(labValues$pid))
    medValues = inner_join(medValues, patient_bday, by="PatientID")

    print("MED: Combine with encounters")
    encountersAll = appendEncounters(encountersAll, medValues)
    medValues = inner_join(medValues, encountersAll, by=c("PatientID", "EncounterID"))
    medValues = excludeValuesEncType(medValues, toInclude)

    print("MED: Calculate Time-Offset")
    medValues = medValues %>% mutate(timeOffset = as.numeric(
                                     as.Date(DoseStartTime) - as.Date(DOB)))
    medValues = medValues %>% rename(pid = PatientID)
    medValues = medValues %>% rename(icd = MedicationTermID)
    medValues = medValues %>% rename(icd_name = MedicationName)

    print("MED: Select columns for output")
    medValues = medValues %>% select(pid, icd, icd_name, timeOffset, EncounterID)

    return(medValues)
}


if (FALSE){
#Parse command line args
cmdLineArgs = prepare_parse_args()
input_val = attr(cmdLineArgs, "input")
startDate = attr(cmdLineArgs, "start")
endDate = attr(cmdLineArgs, "end")
output_filename = attr(cmdLineArgs, "name")
ageBias = attr(cmdLineArgs, "age")
includeSex = attr(cmdLineArgs, "sex")
includeRace = attr(cmdLineArgs, "race")
toInclude = attr(cmdLineArgs, "include")

#Import the lab values
labValues = import_lab_values(input_val, startDate, endDate)

#Load up patient bday
patient_bday = import_patient_bday(labValues$PatientID)

#Filter the lab values
processedResult = process_lab_values(labValues, patient_bday, cmdLineArgs)
labValues = attr(processedResult, "labValues")
encountersAll = attr(processedResult, "encountersAll") 
remove(processedResult)

#Process them for final output
print("LV: Select columns for output")
labValues = labValues %>% rename(pid = PatientID)
labValues = labValues %>% rename(l_val = VALUE)
labValues = labValues %>% select(pid, l_val, timeOffset, EncounterID)

#Get ancillary data
icdValues=prepare_diagnoses(labValues, patient_bday, encountersAll, toInclude)
otherLabs=prepare_other_labs(labValues, patient_bday, encountersAll, toInclude)
otherLabs=prepare_medications(labValues, patient_bday, encountersAll, toInclude)

print("SAVING RESULTS")
parameters<-1:1
attr(parameters, "resultCode") = input_val
attr(parameters, "resultStart") = as.Date(as.POSIXlt(startDate * 86400, origin="1970-01-01"))
attr(parameters, "resultEnd") = as.Date(as.POSIXlt(endDate * 86400, origin="1970-01-01"))
attr(parameters, "race") = includeRace
attr(parameters, "age") = ageBias
attr(parameters, "sex") = includeSex
attr(parameters, "group") = toInclude
attr(parameters, "similarResultCodes") = similarResultCodes
save(parameters, labValues, icdValues, medValues, otherLabs, encountersAll, file=output_filename)
}
