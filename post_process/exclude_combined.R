library(optparse)
library(dplyr)
library(stringr)
source('../import_files.R')

start_excluded_results <- function(outfile){
    write("input, type, code, name, excluded lab count, pre-limit count, percent removed", file=outfile, append=FALSE)
}

write_excluded_results <- function(parameters, theType, tfile, outfile){
    curind = 1
    totalExludeLabCnt = 0

    exclusionList = attr(parameters, paste(theType, "_excluded",sep=""))
    for(x in exclusionList[1,]){
        code = exclusionList[1,curind]
        name = exclusionList[2,curind]
        tcnt = nrow(attr(parameters, paste(theType, "_excluded_labs",sep="")) %>% filter(icd == code))
        totalExludeLabCnt = totalExludeLabCnt + tcnt
        plcnt = attr(parameters,paste(theType, "_pre_limit",sep=""))
        remperct = paste(as.character((as.numeric(tcnt) / as.numeric(plcnt)) * 100), "%", sep="")
        curind = curind + 1
        write(paste(basename(tfile), theType, code, gsub(',','',name), tcnt, plcnt, remperct, sep=","), file=outfile, append=TRUE)
    }

    return(totalExludeLabCnt)
}

append_master_list <- function(parameters, theType, resultCode, masterList){
    excludeList = attr(parameters, paste(theType, "_excluded", sep=""))[1,]
    if(length(excludeList) > 0){
        masterList = cbind(masterList, rbind(resultCode, excludeList))
    }
    return(masterList)
}

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata"),
  make_option("--prefix", type="character", default=NA, help="which files to include with each other")
)

parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
input_dir = args[['input']]
prefixVal = args[['prefix']]

#Variables for keeping track during iterations
masterExcludeICD = list()
masterExcludeMED = list()
masterExcludeLAB = list()
cleanPIDs = list()

#Write the first line in the output file
if(is.na(prefixVal)){
    outfile=paste(input_dir, "/limit_excludes.csv", sep="")
} else {
    outfile=paste(input_dir, "/", tools::file_path_sans_ext(prefixVal), "_limit_excludes.csv", sep="")
}
start_excluded_results(outfile)

listToCombine = c()
searchPath = "joined.Rdata"
if(!is.na(prefixVal)){
    searchPath = prefixVal
}
print(searchPath)
filelist = list.files(input_dir, pattern = searchPath, full.names = TRUE)
print(filelist)
for (tfile in filelist){
    #Load up the file
    load(tfile)

    #Build the name code
    resultNameCode = paste(sort(attr(parameters, "resultCodes")), collapse="_")
    if(resultNameCode %in% names(listToCombine)){
        listToCombine[resultNameCode] = listToCombine[resultNameCode] + 1
    } else {
        listToCombine[resultNameCode] = 1
    }

    #Writeout all excluded codes to text file
    totalExludeLabCnt = 0
    totalExludeLabCnt = totalExludeLabCnt + 
                        write_excluded_results(parameters, "icd", tfile, outfile)
    totalExludeLabCnt = totalExludeLabCnt + 
                        write_excluded_results(parameters, "lab", tfile, outfile) 
    totalExludeLabCnt = totalExludeLabCnt + 
                        write_excluded_results(parameters, "meb", tfile, outfile)
   
    #Append to master list all the codes
    masterExcludeICD = append_master_list(parameters, "icd", resultNameCode, masterExcludeICD)
    masterExcludeLAB = append_master_list(parameters, "lab", resultNameCode, masterExcludeLAB)
    masterExcludeMED = append_master_list(parameters, "med", resultNameCode, masterExcludeMED)

    #Keep track of total unique clean PIDs
    if(nrow(cleanLabValues)){
        cleanPIDs = cbind(cleanPIDs, rbind(resultNameCode, cleanLabValues$pid))
    }

    #Write some output
    print(paste(basename(tfile), ": ", totalExludeLabCnt, " excluded labs", sep=""))
}

#Run each result code seperately
for(curResultCode in names(listToCombine)){
    #Get unique exclusion lists and print some info
    print(paste("COMBINE EXCLUSION: ", curResultCode, " = ", listToCombine[curResultCode], sep=""))
    queryDbForPIDs = TRUE
    if(listToCombine[curResultCode] <= 1){
        queryDbForPIDs = FALSE
    }

    #Query unique exclusions codes
    uniqueExcludeICD = unique(masterExcludeICD[2, which(masterExcludeICD[1,] == curResultCode)])
    uniqueExcludeMED = unique(masterExcludeMED[2, which(masterExcludeMED[1,] == curResultCode)])
    uniqueExcludeLAB = unique(masterExcludeLAB[2, which(masterExcludeLAB[1,] == curResultCode)])
    print(paste("Unique ICDs to Exclude: ", length(uniqueExcludeICD), sep=""))
    print(paste("Unique Meds to Exclude: ", length(uniqueExcludeMED), sep=""))
    print(paste("Unique Labs to Exclude: ", length(uniqueExcludeLAB), sep=""))

    #Get unique lists of PIDs excluded vs included
    uniquePIDs = unique(cleanPIDs[2, which(cleanPIDs[1,] == curResultCode)])
    print(paste("Unique Clean PIDs: ", length(uniquePIDs), sep=""))

    #Get list of patients b-days
    if(queryDbForPIDs){
        patient_bday = import_patient_bday(uniquePIDs)
    }

    #Calculate icd offset
    if(!queryDbForPIDs){
        icdPIDsExclude = list()
    } else {
        icdPIDsExclude <- get_pid_with_icd(uniqueExcludeICD, uniquePIDs)
    }
   
    if(length(icdPIDsExclude) > 0){
        icdPIDsExclude = inner_join(icdPIDsExclude, patient_bday, by="PatientID")
        icdPIDsEncounters = import_encounter_encid(unique(icdPIDsExclude$EncounterID))
        icdPIDsExclude = inner_join(icdPIDsExclude, icdPIDsEncounters, by=c("PatientID", "EncounterID"))
        icdPIDsExclude = icdPIDsExclude  %>% filter(AdmitDate != "")
        icdPIDsExclude = icdPIDsExclude %>% mutate(timeOffsetIcd = as.numeric(
                                                   as.Date(AdmitDate) - as.Date(DOB)))
        icdPIDsExclude = icdPIDsExclude %>% rename(pid = PatientID) %>% select(pid, timeOffsetIcd)
        remove(icdPIDsEncounters)
    }

    #Calculate med offset
    if(!queryDbForPIDs){
        medPIDsExclude = list()
    } else {
        medPIDsExclude <- get_pid_with_med(uniqueExcludeMED, uniquePIDs)
    }

    if(length(medPIDsExclude) > 0){
        medPIDsExclude = inner_join(medPIDsExclude, patient_bday, by="PatientID")
        medPIDsExclude = medPIDsExclude %>% mutate(timeOffsetMed = as.numeric(
                                               as.Date(DoseStartTime) - as.Date(DOB))) 
        medPIDsExclude = medPIDsExclude %>% rename(pid = PatientID) %>% select(pid, timeOffsetMed)
    }

    #Calculate lab offset
    if(!queryDbForPIDs){
        labPIDsExclude = list()
    } else {
        labPIDsExclude <- get_pid_with_result_hlnf(uniqueExcludeLAB, uniquePIDs)
    }
    
    if(length(labPIDsExclude) > 0){
        labPIDsExclude = inner_join(labPIDsExclude, patient_bday, by="PatientID")
        labPIDsExclude = labPIDsExclude %>% mutate(timeOffsetLab = as.numeric(
                                                   as.Date(COLLECTION_DATE) - as.Date(DOB)))
        labPIDsExclude = labPIDsExclude %>% rename(pid = PatientID) %>% select(pid, timeOffsetLab)
    }

    #Clean up data
    if(queryDbForPIDs){
        remove(patient_bday)
    }

    for (tfile in filelist){
        #Load up the file
        load(tfile)
        
        #Check to see if the current file needs to be excluded for the current code
        resultNameCode = paste(sort(attr(parameters, "resultCodes")), collapse="_")
        if(resultNameCode != curResultCode){
            next
        } 

        #Print out some baseline characteristics
        oldCleanLabValues = cleanLabValues

        #Get the abnormal meds and clear them out
        if(length(medPIDsExclude) > 0){
            medCleanLabs = inner_join(medPIDsExclude, cleanLabValues, by="pid")
            medCleanLabs = medCleanLabs %>% mutate(timeDiff = timeOffset - timeOffsetMed) %>% filter(timeDiff > (as.numeric(attr(parameters, "pre_offset")) * -1) && timeDiff < as.numeric(attr(parameters, "post_offset"))) %>% select(pid)
            medCleanLabs = unique(medCleanLabs$pid)
            cleanLabValues = cleanLabValues %>% filter(!pid %in% medCleanLabs)
        }

        if(length(labPIDsExclude) > 0){
            #Get the abnormal labs and clear them out
            labCleanLabs = inner_join(labPIDsExclude, cleanLabValues, by="pid")
            labCleanLabs = labCleanLabs %>% mutate(timeDiff = timeOffset - timeOffsetLab) %>% filter(timeDiff > (as.numeric(attr(parameters, "pre_offset")) * -1) && timeDiff < as.numeric(attr(parameters, "post_offset"))) %>% select(pid)
            labCleanLabs = unique(labCleanLabs$pid)
            cleanLabValues = cleanLabValues %>% filter(!pid %in% labCleanLabs)
        }

        if(length(icdPIDsExclude) > 0){        
            #Get abnormal icdss and clear them out
            icdCleanLabs = inner_join(icdPIDsExclude, cleanLabValues, by="pid")
            icdCleanLabs = icdCleanLabs %>% mutate(timeDiff = timeOffset - timeOffsetIcd) %>% filter(timeDiff > (as.numeric(attr(parameters, "pre_offset")) * -1) && timeDiff < as.numeric(attr(parameters, "post_offset"))) %>% select(pid)
            icdCleanLabs = unique(icdCleanLabs$pid)
            cleanLabValues = cleanLabValues %>% filter(!pid %in% icdCleanLabs)
        }

        #Update some info
        attr(parameters, "combined_excluded_labs") = setdiff(oldCleanLabValues, cleanLabValues)
        attr(parameters, "combined_count") = nrow(cleanLabValues)
        
        #Save the results
        print(paste(basename(tfile), " to filter: ", nrow(oldCleanLabValues), " => ", nrow(cleanLabValues), sep=""))
        save(cleanLabValues, parameters, file=str_replace(tfile,"joined","combined"))
    }
}

