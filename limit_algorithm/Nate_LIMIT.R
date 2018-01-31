## Default Arguments
criticalProp = 0.005 # beta
criticalP = 0.1 # alpha
criticalHampel = 2 # t
day_time_offset_post = 120 # n
day_time_offset_pre = 120 # n2, an addition to the Poole method

#Count the number of CPUs available
cpuCnt<-system("nproc", ignore.stderr = TRUE, intern = TRUE)
parallelCores<-strtoi(cpuCnt)

#Load up the data from command line argument
library(optparse)
library(dplyr)
library(parallel)
library(boot)

#Create the options list
option_list <- list(
  make_option("--output", type="character", default="/scratch/leeschro_armis/patnatha/limit_results/", help="directory to put results"),
  make_option("--input", type="character", default=NA, help="file to load Rdata"),
  make_option("--name", type="character", default=NA, help="name of file to output"),
  make_option("--codes", type="character", default="icd", help="which codes to run against [med|icd|lab]"),
  make_option("--critical-proportion", type="double", default=NA, help="critical proportion of icd values to perform fishers"),
  make_option("--critical-p-value", type="double", default=NA, help="critical p-value for fisher's test cutoff"),
  make_option("--critical-hampel", type="integer", default=NA, help="hampel algorithm cutoff"),
  make_option("--day-time-offset-post", type="integer", default=NA, help="Offset in days from lab values to include values"),
  make_option("--day-time-offset-pre", type="integer", default=NA, help="Offset in days from lab values to include values"),
  make_option("--singular-value", type="character", default=NA, help="How to choose the patients value")
)

#Parse the incoming options
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

#Assign the parsed options to their variable
outputDir = args[['output']]
outputName = args[['name']]
inputData = args[['input']]
codeType = args[['codes']]
singular_value = args[['singular-value']]
versioning = '1.3'

# Parse the incoming critical proportion
if(!is.na(args[['critical-proportion']])){
    criticalProp = as.numeric(args[['critical-proportion']])
}

# Parse the incoming critical p-value
if(!is.na(args[['critical-p-value']])){
    criticalP = as.numeric(args[['critical-p-value']])
}

# Parse the incoming critical hampel value
if(!is.na(args[['critical-hampel']])){
    criticalHampel = as.numeric(args[['critical-hampel']])
}

# parse the incoming day offset post
if(!is.na(args[['day-time-offset-post']])){
    day_time_offset_post = as.numeric(args[['day-time-offset-post']])
}

# Parse the incoming day offset pre
if(!is.na(args[['day-time-offset-pre']])){
    day_time_offset_pre = as.numeric(args[['day-time-offset-pre']])
}

#Check the output directory exists
if(!dir.exists(outputDir)){
    print("ERROR: The output directory doesn't exist")
    stop()
}

#Check to make sure the name parameter was set
if(is.na(outputName)){
    outputName = strsplit(basename(inputData), "[.]")[[1]][[1]]
    outputName = paste(outputName, codeType, sep="_")
}

#Create the output file
saving = gsub('//', '/', paste(outputDir, outputName, sep="/"))
saving = paste(saving, '.Rdata', sep="")

#Check to see if the file exists
if(file.exists(saving)){
    print("ERROR: File Already Exists")
    stop()
} 

# Parse the singular_value parameter
if(is.na(singular_value)){
    singular_value = "all"
} else if(singular_value != "random" && singular_value != "most_recent"){
    print("ERROR: incorrect singular_value")
    stop()
} else {
    singular_value = singular_value
}

#Load RData from disk
if(is.na(inputData) || !file.exists(inputData)){
    print("ERROR: The input file path doesn't exist")
    stop()
}
print(paste("Loading Data: ", inputData, sep=""))
load(inputData);

#Check to see if the code type had been selected
if(!is.na(codeType)){
    # Run algorithm against administered medicines
    if(codeType == 'med'){
        icdValues = medValues
    }
    else if(codeType == 'lab'){
        icdValues = otherLabs
    }
    else if(codeType == 'icd'){
        icdValues = icdValues
    }
    else{
        print("ERROR: Input code type is not valid")
        stop()
    }
}else{
    print("ERROR: A code type has not been selected [icd|med|lab]")
    stop()
}

#Save all the parameters to a structure
if(!exists("parameters")){
    parameters<-1:1
}
attr(parameters, "criticalProp") <- criticalProp
attr(parameters, "criticalP") <- criticalP
attr(parameters, "criticalHampel") <- criticalHampel
attr(parameters, "outputDir") <- outputDir
attr(parameters, "outputName") <- outputName
attr(parameters, "day_time_offset_pre") <- day_time_offset_pre
attr(parameters, "day_time_offset_post") <- day_time_offset_post
attr(parameters, "codeType") <- codeType
attr(parameters, "versioning") <- versioning
attr(parameters, "inputData") <- inputData
attr(parameters, "singular_value") <- singular_value

#Run the hampel outlier detection
hampel = function(x, t = 3, RemoveNAs = TRUE) {
  #
  #  This procedure returns an index of x values declared
  #  outliers according to the Hampel detection rule, if any
  #
  mu = median(x, na.rm = RemoveNAs)
  sig = mad(x, na.rm = RemoveNAs)
  indx = which(abs(x - mu) > t * sig)
  
  return(indx)
}

FindICDs = function(pid, data, icdValues, day_time_offset_post, day_time_offset_pre) {
    if(is.na(pid) | is.null(pid) | pid == ""){
        return(list())
    }

    # Get the first timestamp of labValue for the input pid
    theTime = min(data$timeOffset[which(data$pid == pid)])

    # Return NA for errors
    if(is.na(theTime) | is.null(theTime)){
        return(list())
    }

    # Get ICD values assigned before the time of the lab value
    ind = which(icdValues$pid == pid & 
                icdValues$timeOffset <= (as.numeric(theTime) + day_time_offset_post) & 
                icdValues$timeOffset >= (as.numeric(theTime) - day_time_offset_pre))

    # Get the unique list of ICD values
    codes = unique(icdValues$icd[ind])

    # Return the list of codes 
    return(codes) 
}

PerformFishertestICD = function(ICD, icdValues, flaggedTable, totalFlagged, unflagged) { 
    if (!is.na(ICD)) {
        # Find number of flagged patients with the code of interest, and calculate number without
        numFlaggedWithCode = flaggedTable[which(flaggedTable$icd == ICD),]$freq
        numFlaggedWithoutCode = totalFlagged - numFlaggedWithCode

        # Get the pids that use this ICD 
        allWithCode = unique(icdValues$pid[which(icdValues$icd == as.character(ICD))])

        # Find number of unflagged patients who have this code, and number who do not
        numUnflaggedWithCode = length(intersect(unflagged, allWithCode))
        numUnflaggedWithoutCode = length(unflagged) - numUnflaggedWithCode
        
        # Perform Fisher's exact test to see if flagged population has significantly higher proportion of patients with this code. Return p value
        fisherResult = fisher.test(matrix(c(numFlaggedWithCode, numFlaggedWithoutCode, numUnflaggedWithCode, numUnflaggedWithoutCode), nrow = 2), alternative = "greater")
        
        return(fisherResult$p.value)  
    } else {
        return(0)
    }
}

FindExclusions = function(disease) {
    #Get list of unique PIDs that have the input value
    exclude1 = unique(icdValues$pid[which(icdValues$icd == disease)])
    return(exclude1)
}

# Remove the empty values and numericize the column of interest
labValues = labValues %>% filter(!is.na(pid) & !is.null(pid) & !pid == "")
labValues = labValues %>% filter(!is.na(l_val))
labValues$l_val = as.numeric(labValues$l_val)
labValues = labValues  %>% filter(!is.na(l_val))

# Obtain only one value for each PID
if(singular_value == "most_recent"){
    # Find the most recent value for a grouping of PIDs
    mostRecentLabValues = labValues %>% group_by(pid) %>% summarise(timeOffset=max(timeOffset))

    # Get the lab values for the first day for each PID, pick a random value on the first day
    labValues = labValues %>% inner_join(mostRecentLabValues, by=c("pid", "timeOffset") %>% group_by(pid) %>% sample_n(1))
    remove(mostRecentLabValues)
} else if(singular_value == "random"){
    # Get a list of random values for each PID
    labValues = labValues %>% group_by(pid) %>% sample_n(1) %>% select(pid, l_val, EncounterID, timeOffset)
}

# Write down the pre-limit length algorithm
attr(parameters, "pre-limit_quantiles") = as.numeric(quantile(labValues$l_val, c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE))
attr(parameters, "pre-limit_count") = nrow(labValues) 

#Print the original results
print(paste("Lab Values Count: ", nrow(labValues)))
print(paste("Patient Count: ", length(unique(labValues$pid))))
print(paste("Lab Values Quantiles: ", paste(as.numeric(quantile(labValues$l_val, c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)), collapse=" ")))

# Create data set
labValues$outlier = rep(FALSE, length(labValues$pid))

# Initialise logical convergence indicator
converged = FALSE

# Structures to keep track of excluded items
excludedICDs = list()
excludedICDNames = list()
excludedPatients = list()
excludedCounts = list()
excludedPval = list()

# Get the mean and MAD of the lab values
mu = median(labValues$l_val, na.rm = TRUE)
sig = mad(labValues$l_val, na.rm = TRUE)

#CONVERGE
debug = TRUE
iteration = 0
while (!converged) {
    # Initialise indices of outliers using Hampels method
    outliers = hampel(labValues$l_val, criticalHampel, TRUE)
    labValues$outlier[outliers] = TRUE

    #Print some interation output for notification
    iteration = iteration + 1

    # Only run algorith if there are some non-outliers
    if (length(which(labValues$outlier == FALSE)) > 100) {
        # Create lists of patients with flagged tests
        flaggedPatients = unique(labValues$pid[which(labValues$outlier == TRUE)])
        totalFlaggedPatients = length(flaggedPatients)

        if(debug){
            print(paste("Flagged Patients (", as.character(iteration), "): ", totalFlaggedPatients, sep=""))
        }

        #Create  lists of patients with unflagged test
        unflaggedPatients = setdiff(unique(labValues$pid), flaggedPatients)
        totalUnflaggedPatients = length(unflaggedPatients)

        # Create list of flagged test results 
        flaggedResults = labValues[which(labValues$outlier == TRUE),]
        
        #Order the values based on age
        flaggedResults = flaggedResults[order(flaggedResults$timeOffset), ]

        #Remove duplicate pids
        flaggedResults = flaggedResults[!(duplicated(flaggedResults$pid)), ]

        if(debug){
            print(paste("Flagged Results (", as.character(iteration), "): ", length(flaggedResults$pid), sep=""))   
        }

        if (length(flaggedResults$pid) > 4) {
            # Find all ICD codes for patients with flagged test results, before the first test
            start.time <- Sys.time()
            #ICDs = sapply(flaggedPatients, FindICDs, flaggedResults, icdValues, day_time_offset_post, day_time_offset_pre)
            cl = makeCluster(parallelCores, outfile='~/parSapply.out')
            ICDs = parSapply(cl=cl, flaggedPatients, FindICDs, flaggedResults, icdValues, day_time_offset_post, day_time_offset_pre)
            stopCluster(cl)
            if(debug){
                time.taken <- as.numeric(Sys.time() - start.time, units="secs")
                print(paste("Finding ICDs (", as.character(iteration), "): ", as.character(round(time.taken, digits=2)), " secs", sep=""))
            }

            # Process the results
            ICDtable = NA
            if (length(ICDs) != 0 ) {
                # Flatten the list of ICDs with frequencies
                ICDtable = as.data.frame(table(unlist(ICDs, recursive=FALSE)), useNA = 'no')
            }
            
            if(!is.na(ICDtable) && ncol(ICDtable) == 2 && nrow(ICDtable) > 0){
                #Rename the columns
                ICDtable$icd = ICDtable$Var1
                ICDtable$freq = ICDtable$Freq
                ICDtable = ICDtable[c("icd", "freq")]
                
                #Order the ICD tables on freq
                ICDtable = ICDtable[order(ICDtable$freq, decreasing = TRUE), ]

                # Calculate the limit value
                limit = which(ICDtable$freq <= ceiling(totalFlaggedPatients * criticalProp))[1] - 1
                if (is.na(limit)) {
                    limit = length(ICDtable$freq)
                }

                # Perform Fisher's exact test on this table 
                start.time <- Sys.time()
                #fisherTestICD = sapply(ICDtable[(1:limit),]$icd, PerformFishertestICD, icdValues, ICDtable, totalFlaggedPatients, unflaggedPatients)
                cl <- makeCluster(parallelCores)
                fisherTestICD = parSapply(cl=cl, ICDtable[(1:limit),]$icd, PerformFishertestICD, icdValues, ICDtable, totalFlaggedPatients, unflaggedPatients)                
                stopCluster(cl)

                #Do the Bonferroni correction
                fisherTestICD = p.adjust(fisherTestICD, method = 'bonferroni')

                if(debug){
                    time.taken <- as.numeric(Sys.time() - start.time, units="secs")
                    print(paste("Fisher Testing (", as.character(iteration), "): ", as.character(round(time.taken, digits=2)), " secs", sep=""))
                }

                # Get the minumum Fisher value 
                pvalue = min(fisherTestICD)

                if (pvalue > criticalP) {
                    converged = TRUE
                    excludePID = numeric()
                } else {
                    # Removing ICD
                    DOI = as.character(ICDtable[which.min(fisherTestICD),]$icd)
                    print(paste('CODE (', as.character(iteration), "): ", DOI, sep=""))

                    #Find the ICD code for this given name
                    DOIName = unique(icdValues$icd_name[which(icdValues$icd == DOI)])
                    print(paste('CODE NAME (', as.character(iteration), "): ", DOIName, sep=""))

                    # Find all patients who have the significant codes
                    excludePID = FindExclusions(DOI)

                    #Keep track of which codes were excluded and their p-values at exclusion 
                    excludedICDs = c(excludedICDs, DOI)
                    excludedICDNames = c(excludedICDNames, DOIName)
                    excludedPatients = append(excludedPatients, excludePID)
                    excludedCounts = c(excludedCounts, 
                                        length(which(labValues$pid %in% excludePID)))
                    excludedPval = c(excludedPval, pvalue)
                }
            } else {
                excludePID = numeric()
                converged = TRUE
            }
          
            # Remove excluded patients from data base
            includePatients = setdiff(unique(labValues$pid), excludePID)
            labValues = labValues[which(labValues$pid %in% includePatients), ]
        } else {
            converged = TRUE
        }
    } else {
        converged = TRUE
    }
}

print(paste("Lab Values Count: ", nrow(labValues)))
print(paste("Patient Count: ", length(unique(labValues$pid))))
print(paste("Lab Values Quantiles: ", paste(as.numeric(quantile(labValues$l_val, c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)), collapse=" ")))

#Save the updated labValues and excluded ICD values
cleanLabValues = labValues %>% select(pid, l_val, timeOffset, EncounterID)
save(parameters, cleanLabValues, excludedPatients, excludedICDs, excludedICDNames, excludedCounts, excludedPval, file=saving)

