library(optparse)
library(dplyr)
source('../import_files.R')

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata")
)

parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
input_dir = args[['input']]

#Variables for keeping track during iterations
masterExcludePidList = list()
masterExcludeICD = list()
masterExcludeMED = list()
masterExcludeLAB = list()
uniquePIDs = list()

#Write the first line in the output file
outfile=paste(input_dir, "/icd_med_lab_excludes.csv", sep="")
write("input, type, code, name, excluded lab count, pre-limit count, percent removed", file=outfile, append=FALSE) 

filelist = list.files(input_dir, pattern = ".Rdata", full.names = TRUE)
for (tfile in filelist){
    #Load up the file
    load(tfile)

    #Create master exclusion list
    tempExclude = unique(c(attr(parameters, "lab_exclude_pid"), attr(parameters, "icd_excluded_pid"), attr(parameters, "med_excluded_pid")))
    print(paste(basename(tfile), " to exclude: ", length(tempExclude), sep=""))
    masterExcludePidList = c(masterExcludePidList, tempExclude)

    #Writeout all the icds
    curind = 1
    for(x in attr(parameters, "icd_excluded")[1,]){
        code = (attr(parameters, "icd_excluded")[1,curind])
        name = (attr(parameters, "icd_excluded")[2,curind])
        tcnt = (attr(parameters, "icd_excluded")[3,curind])
        plcnt = attr(parameters,"icd_pre_limit")
        remperct = paste(as.character((as.numeric(tcnt) / as.numeric(plcnt)) * 100), "%", sep="")
        curind = curind + 1
        write(paste(basename(tfile), "icd", code, gsub(',','',name), tcnt, plcnt, remperct, sep=","), file=outfile, append=TRUE)
    }

    #Write out all the labs
    curind = 1
    for(x in attr(parameters, "lab_excluded")[1,]){
        code = (attr(parameters, "lab_excluded")[1,curind])
        name = (attr(parameters, "lab_excluded")[2,curind])
        tcnt = (attr(parameters, "lab_excluded")[3,curind])
        plcnt = attr(parameters,"lab_pre_limit")
        remperct = paste(as.character((as.numeric(tcnt) / as.numeric(plcnt)) * 100), "%", sep="")
        curind = curind + 1
        write(paste(basename(tfile), "lab", code, gsub(',','',name), tcnt, plcnt, remperct, sep=","), file=outfile, append=TRUE)
    }

    #Write out all the meds
    curind = 1
    for(x in attr(parameters, "med_excluded")[1,]){
        code = (attr(parameters, "med_excluded")[1,curind])
        name = (attr(parameters, "med_excluded")[2,curind])
        tcnt = (attr(parameters, "med_excluded")[3,curind])
        plcnt = attr(parameters,"med_pre_limit")
        remperct = paste(as.character((as.numeric(tcnt) / as.numeric(plcnt)) * 100), "%", sep="")
        curind = curind + 1
        write(paste(basename(tfile), "med", code, gsub(',','',name), tcnt, plcnt, remperct, sep=","), file=outfile, append=TRUE)
    }

    #Append to master lists
    masterExcludeICD = c(masterExcludeICD, attr(parameters, "icd_excluded")[1,])
    masterExcludeMED = c(masterExcludeMED, attr(parameters, "med_excluded")[1,])
    masterExcludeLAB = c(masterExcludeLAB, attr(parameters, "lab_excluded")[1,])

    #Keep track of total unique PIDs
    uniquePIDs = c(uniquePIDs, cleanLabValues$pid)
}

#Get unique exclusion lists and print some info
masterExcludeICD = unique(masterExcludeICD)
masterExcludeMED = unique(masterExcludeMED)
masterExcludeLAB = unique(masterExcludeLAB)
print(paste("Unique ICDs to Exclude: ", length(masterExcludeICD), sep=""))
print(paste("Unique Meds to Exclude: ", length(masterExcludeMED), sep=""))
print(paste("Unique Labs to Exclude: ", length(masterExcludeLAB), sep=""))

#Get unique lists of PIDs excluded vs included
masterExcludePidList = unique(masterExcludePidList)
print(paste("Unique Excluded PIDs: ", length(masterExcludePidList), sep=""))
uniquePIDs = unique(uniquePIDs)
print(paste("Unique Clean PIDs: ", length(uniquePIDs), sep=""))

#Get list of patients b-days
patient_bday = import_patient_bday(uniquePIDs)

#Calculate icd offset
icdPIDsExclude <- get_pid_with_icd(masterExcludeICD, uniquePIDs)
icdPIDsExclude = inner_join(icdPIDsExclude, patient_bday, by="PatientID")
icdPIDsEncounters = import_encounter_all(unique(icdPIDsExclude$PatientID))
icdPIDsExclude = inner_join(icdPIDsExclude, icdPIDsEncounters, by=c("PatientID", "EncounterID"))
icdPIDsExclude = icdPIDsExclude %>% mutate(timeOffsetIcd = as.numeric(
                                           as.Date(AdmitDate) - as.Date(DOB)))
icdPIDsExclude = icdPIDsExclude %>% rename(pid = PatientID) %>% select(pid, timeOffsetIcd)

#Calculate med offset
medPIDsExclude <- get_pid_with_med(masterExcludeMED, uniquePIDs)
medPIDsExclude = inner_join(medPIDsExclude, patient_bday, by="PatientID")
medPIDsExclude = medPIDsExclude %>% mutate(timeOffsetMed = as.numeric(
                                           as.Date(DoseStartTime) - as.Date(DOB))) 
medPIDsExclude = medPIDsExclude %>% rename(pid = PatientID) %>% select(pid, timeOffsetMed)

#Calculate lab offset
labPIDsExclude <- get_pid_with_result_hlnf(masterExcludeLAB, uniquePIDs)
labPIDsExclude = inner_join(labPIDsExclude, patient_bday, by="PatientID")
labPIDsExclude = labPIDsExclude %>% mutate(timeOffsetLab = as.numeric(
                                           as.Date(COLLECTION_DATE) - as.Date(DOB)))
labPIDsExclude = labPIDsExclude %>% rename(pid = PatientID) %>% select(pid, timeOffsetLab)

#Clean up data
remove(icdPIDsEncounters)
remove(patient_bday)

for (tfile in filelist){
    #Load up the file
    load(tfile)

    #Print out some baseline characteristics
    oldCleanLabValuesLen = nrow(cleanLabValues)

    #Get the abnormal meds and clear them out
    medCleanLabs = inner_join(medPIDsExclude, cleanLabValues, by="pid")
    medCleanLabs = medcleanLabs %>% mutate(timeDiff = timeOffset - timeOffsetMed) %>% filter(timeDiff > (as.numeric(attr(parameters, "med_pre_offset")) * -1) && timeDiff < as.numeric(attr(parameters, "med_post_offset"))) %>% select(pid)
    medCleanLabs = unique(medCleanLabs$pid)
    cleanLabValues = cleanLabValues %>% filter(!pid in medCleanLabs)

    #Get the abnormal labs and clear them out
    labCleanLabs = inner_join(labPIDsExclude, cleanLabValues, by="pid")
    labCleanLabs = labCleanLabs %>% mutate(timeDiff = timeOffset - timeOffsetLab) %>% filter(timeDiff > (as.numeric(attr(parameters, "lab_pre_offset")) * -1) && timeDiff < as.numeric(attr(parameters, "lab_post_offset"))) %>% select(pid)
    labCleanLabs = unique(labCleanLabs$pid)
    cleanLabValues = cleanLabValues %>% filter(!pid in labCleanLabs)

    #Get abnormal icdss and clear them out
    icdCleanLabs = inner_join(icdPIDsExclude, cleanLabValues, by="pid")
    icdCleanLabs = icdCleanLabs %>% mutate(timeDiff = timeOffset - timeOffsetIcd) %>% filter(timeDiff > (as.numeric(attr(parameters, "icd_pre_offset")) * -1) && timeDiff < as.numeric(attr(parameters, "icd_post_offset"))) %>% select(pid)
    icdCleanLabs = unique(icdCleanLabs$pid)
    cleanLabValues = cleanLabValues %>% filter(!pid in icdCleanLabs)

    #Print some output of results
    print(paste(basename(tfile), " to filter: ", oldCleanLabValuesLen, " => ", nrow(cleanLabValues), sep=""))

    #Save the update results
    save(cleanLabValues, parameters, file=tfile)
}

