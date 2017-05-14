# ------------------------------------------------------------------- #
#                           LIMIT.R                                   #
#                         Author - Sarah Poole                        #
#                          Date - 3 April 2014                        #
# ------------------------------------------------------------------- #

## Arguments:
# criticalProp = 0.005
# criticalP = 0.05
# criticalHampel = 3
# saving = 'name_of_output_file'
# dataType = one of: 'PROLACTIN', SODIUM', 'POTASSIUM', 'TOTAL_PROTEIN', TESTOSTERONE_AGE', 'TESTOSTERONE_RACE', 'HGB1F', 'HGB1M', 'HGB2F', 'HGB2M', 'HGB3F', 'HGB3M', 'ALT'  
# logData = logical, should data be logged
# day_time_offset = numeric, the number of days after abnormal test result that ICD9 codes are included for - have used 5 days or 0 days

# ------------------------------------------------------------------- #
# Set-up
# ------------------------------------------------------------------- #

# Allows arguments passed in through the command line to be used
args = commandArgs(TRUE)

# Stops execution if path name argument is not entered
if (length(args) != 7) {
  stop("Error: wrong number of arguments")
}

criticalProp = as.numeric(args[1])
criticalP = as.numeric(args[2])
criticalHampel = as.numeric(args[3])
saving = args[4]
dataType = args[5]
logData = as.logical(args[6])
day_time_offset = as.numeric(args[7])

# dataPath is the location of an R file containing a dataframe named 'data' with all 
# lab results of interest and demographic information. See 'sodium.R' for example.
# ICD9Path is the location of an R file containing a dataframe named 'separateICD9s' with all 
# ICD9 codes for the patients of interest, with columns 'pid', 'icd9', 'timeoffset'. 
if (dataType == 'SODIUM') {
  dataPath = 'LABNAVisitChecked.Rdata'
  ICD9Path = 'sodiumICD9s.Rdata'
  numCats = 1
} else if (dataType == 'POTASSIUM') {
  dataPath = 'LABKVisitChecked.Rdata'
  ICD9Path = 'potassiumICD9s.Rdata'
  numCats = 1
} else if (dataType == 'TOTAL_PROTEIN') {
  dataPath = 'totalProteinData.Rdata'
  ICD9Path = 'totalProteinICD9s.Rdata'
  numCats = 1
} else if (dataType == 'TESTOSTERONE_AGE') { 
  dataPath = 'testosteroneData_revised.Rdata'
  ICD9Path = 'testosteroneICD9s_revised.Rdata'
  numCats = 2
} else if (dataType == 'TESTOSTERONE_RACE') {
  dataPath = 'testosteroneData_revised.Rdata'
  ICD9Path = 'testosteroneICD9s_revised.Rdata'
  numCats = 7
} else if (dataType == 'HGB') {
  dataPath = 'HGBdata.Rdata'
  ICD9Path = 'HGBICD9s.Rdata'
  numCats = 6
  load('haemCodeLists.Rdata')
} else if (dataType == 'ALT') {
  dataPath = 'ALTData.Rdata'
  ICD9Path = 'ALTICD9s.Rdata'
  numCats = 2
} else if (dataType == 'PROLACTIN') {
  dataPath = 'prolactin_Data.Rdata'
  ICD9Path = 'prolactin_ICD9s.Rdata'
  numCats = 3
} 

# Load libraries   
library(stats)    
library(DBI)
library(RMySQL)
library(forecast)

# Set working directory 
# TODO: if desired

# Connect to SQL database
# Note: password has been removed for security reasons, so this code will not run
drv = dbDriver("MySQL")
con = dbConnect(drv, user = "spoole", host = "ncbolabs-db1.stanford.edu", password = "*****")

# data is a database containing all hemoglobin lab results from STRIDE5, as well as demographic information for the patients.
# This database is created in DataExtraction.R
load(dataPath)
load(ICD9Path)


separateICD9s$icd9 = as.character(separateICD9s$icd9)

# ------------------------------------------------------------------- #
# Functions 
# ------------------------------------------------------------------- #

# Finds all ICD9 codes recorded for a given patient, before a given time
# Patient number and time offset are stored in the 'data' input, at index
# number given by the 'index' input.
# Returns a list of unique codes
FindICD9s = function(patient, data) {
  time = min(data$timeoffset[which(data$pid == patient)])
  ind = intersect(which(separateICD9s$pid == as.numeric(patient)), which(separateICD9s$timeoffset <= (as.numeric(time) + day_time_offset)))
  codes = unique(separateICD9s$icd9[ind])
  return(codes) 
}

# Performs Fishers exact test to check whether an ICD9 code is overrepresented in 
# flagged patients (patients with out of range test results) compared to unflagged patients.
# Input 'ICD9' specifies the ICD9 code that is being compared. Input 'flaggedTable' contains
# all ICD9 codes of interest, and the number of flagged patients who have this code. Input
# 'totalFlagged' gives the total number of patients who are flagged. Input 'unflagged' gives the 
# total number of unflagged patients. 
# Returns the p value from the Fisher's exact test
PerformFishertestICD9 = function(ICD9, flaggedTable, totalFlagged, unflagged) { 
  if (!is.na(ICD9)) {
    # Find number of flagged patients with the code of interest, and calculate number without
    numFlaggedWithCode = flaggedTable[which(flaggedTable[, 1] == ICD9), 2]
    numFlaggedWithoutCode = totalFlagged - numFlaggedWithCode
    # Query the SQL database to find all patients with this code
    #query = sprintf("SELECT DISTINCT pid FROM user_spoole.sarah_icd9s WHERE icd9 = \'%s\'", as.character(ICD9))
    #allWithCode = dbGetQuery(con, query) 
    if (grepl('HGB', dataType)) {
      allWithCode = unlist(codeLists[[which(names(codeLists) == as.character(ICD9))]])
    } else {
      allWithCode = unique(separateICD9s$pid[which(separateICD9s$icd9 == as.character(ICD9))])
    }
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
  exclude1 = unique(separateICD9s$pid[which(separateICD9s$icd9 == disease)])
  return(exclude1)
}

hampel = function(x, t = 3, RemoveNAs = TRUE) {
  #
  #  This procedure returns an index of x values declared
  #  outliers according to the Hampel detection rule, if any
  #
  mu = median(x, na.rm = RemoveNAs)
  sig = mad(x, na.rm = RemoveNAs)
  indx = which(abs(x - mu) > t *sig)
  
  return(indx)
}

getICD9Names = function(ICD9) {
  
  query = sprintf("SELECT DISTINCT STR FROM umls2011ab.MRCONSO WHERE SAB = \'ICD9CM\' AND CODE = \'%s\'", as.character(ICD9))
  name = dbGetQuery(con, query)[[1]][1]
  return(name)
  
}

# ------------------------------------------------------------------- #
# Code
# ------------------------------------------------------------------- #

# Filtering out patients with no ICD9s
noCodes = setdiff(unique(data$pid), unique(separateICD9s$pid))
noCodeInds = which(data$pid %in% noCodes)
if (length(noCodeInds) > 0) {
  data = data[-noCodeInds, ]
}

# Create data set
data$outlier = rep(FALSE, length(data$pid))

if (logData) {
  data$ord_num = log(as.numeric(data$ord_num))
}

# Initialise logical convergence indicator
converged = FALSE

# Initialise iteration value
iteration = 1

# Defining categories for different lab tests
if (dataType == 'SODIUM' || dataType == 'POTASSIUM' || dataType == 'TOTAL_PROTEIN') {
  cohortSP = unique(data$pid[which(data$age > 18)])
} else if (dataType == 'TESTOSTERONE_AGE') { 
  cohortAdult = unique(data$pid[intersect(intersect(which(data$age > 18), which(data$age <= 55)), which(data$gender == "MALE"))])
  cohortOlder = unique(data$pid[intersect(which(data$age > 55), which(data$gender == "MALE"))])
} else if (dataType == 'TESTOSTERONE_RACE') {
  cohortWhite = unique(data$pid[intersect(which(data$race == "WHITE"), which(data$gender == "MALE"))])
  cohortOther = unique(data$pid[intersect(which(data$race == "OTHER"), which(data$gender == "MALE"))])
  cohortBlack = unique(data$pid[intersect(which(data$race == "BLACK"), which(data$gender == "MALE"))])
  cohortUnknown = unique(data$pid[intersect(which(data$race == "UNKNOWN"), which(data$gender == "MALE"))])
  cohortNativeAmerican = unique(data$pid[intersect(which(data$race == "NATIVE AMERICAN"), which(data$gender == "MALE"))])
  cohortAsian = unique(data$pid[intersect(which(data$race == "ASIAN"), which(data$gender == "MALE"))])
  cohortPacificIslander = unique(data$pid[intersect(which(data$race == "PACIFIC ISLANDER"), which(data$gender == "MALE"))])
} else if (dataType == 'HGB') {
  cohort1F = unique(data$pid[intersect(which(data$gender == "FEMALE"), intersect(which(data$age >= 2), which(data$age < 6)))])
  cohort1M = unique(data$pid[intersect(which(data$gender == "MALE"), intersect(which(data$age >= 2), which(data$age < 6)))])                   
  cohort2F = unique(data$pid[intersect(which(data$gender == "FEMALE"), intersect(which(data$age >= 6), which(data$age < 12)))])
  cohort2M = unique(data$pid[intersect(which(data$gender == "MALE"), intersect(which(data$age >= 6), which(data$age < 12)))])
  cohort3F = unique(data$pid[intersect(which(data$gender == "FEMALE"), which(data$age >= 12))])
  cohort3M = unique(data$pid[intersect(which(data$gender == "MALE"), which(data$age >= 12))])
} else if (dataType == 'PROLACTIN') {
  cohortMale = unique(data$pid[which(data$gender == "MALE")])
  cohortFemale = unique(data$pid[which(data$gender == "FEMALE")])
  cohortNotPregnant = setdiff(cohortFemale, intersect(cohortFemale, unique(separateICD9s$pid[which(as.character(separateICD9s$icd9) == 'V22.2')])))
} else if (dataType == 'ALT') {
  cohortMale = unique(data$pid[which(data$gender == "MALE")])
  cohortFemale = unique(data$pid[which(data$gender == "FEMALE")])
}


# Find all test results for patients in the sub-cohorts
if (dataType == 'SODIUM' || dataType == 'POTASSIUM' || dataType == 'TOTAL_PROTEIN') {
  data = data[which(data$pid %in% cohortSP), ]
} else if (dataType == 'HGB') {
  # HGB has multiple catefories
  c1F = data[which(data$pid %in% cohort1F), ]
  c1M = data[which(data$pid %in% cohort1M), ]
  c2F = data[which(data$pid %in% cohort2F), ]
  c2M = data[which(data$pid %in% cohort2M), ]
  c3F = data[which(data$pid %in% cohort3F), ]
  c3M = data[which(data$pid %in% cohort3M), ]
}

results = matrix(0, numCats, 3)
colnames(results) = c('Low.Limit', 'High.Limit', 'N')

excludedICD9s = list(numeric(0))

exclusionCounts = list(numeric(0))

exclusionII = list(numeric(0))

exclusionPval = list(numeric(0))

# One loop done per sub-cohort
for (ii in 1:numCats) {
  
  print(ii)
    
  if (dataType == 'TESTOSTERONE_AGE') { 
    if (ii == 1) {
      data = cAdultVals
    } else if (ii == 2) {
      data = cOlderVals
    } 
  } else if (dataType == 'TESTOSTERONE_RACE') {
    if (ii == 1) {
      data = cWhiteVals
    } else if (ii == 2) {
      data = cOtherVals
    } else if (ii == 3) {
      data = cBlackVals
    } else if (ii == 4) {
      data = cUnknownVals
    } else if (ii == 5) {
      data = cNativeAmericanVals
    } else if (ii == 6) {
      data = cAsianVals
    } else if (ii == 7) {
      data = cPacificIslanderVals
    } 
  } else if (dataType == 'PROLACTIN') {
    if (ii == 1) {
      data = cMaleVals
    } else if (ii == 2) {
      data = cFemaleVals
    } else if (ii == 3) {
      data = cNotPregnantVals
    }
  } else if (dataType == 'ALT') {
    if (ii == 1) {
      data = cMaleVals
    } else if (ii == 2) {
      data = cFemaleVals
    } 
  } else if (dataType == 'HGB') {
    if (ii == 1) {
      data = c1F
    } else if (ii == 2) {
      data = c1M
    } else if (ii == 3) {
      data = c2F
    } else if (ii == 4) {
      data = c2M
    } else if (ii == 5) {
      data = c3F
    } else if (ii == 6) {
      data = c3M
    } 
  }
  
  # Initialise logical convergence indicator
  converged = FALSE
  
  # Initialise iteration value
  iteration = 1
  
  excludedIngrs = numeric()
  
  mu = median(as.numeric(data$ord_num), na.rm = TRUE)
  sig = mad(as.numeric(data$ord_num), na.rm = TRUE)
  
  # Repeat this loop until convergence occurs
  while (!converged) {
    
    # Initialise indices of outliers
    outliers = hampel(as.numeric(data$ord_num), criticalHampel, TRUE)
    data$outlier[outliers] = TRUE
    
    iteration = iteration + 1
    
    if (length(which(data$outlier == FALSE)) > 100) {
      # Create lists of patients with flagged and unflagged haemoglobin tests
      flaggedPatients = unique(data$pid[which(data$outlier == TRUE)])
      totalFlaggedPatients = length(flaggedPatients)
      unflaggedPatients = setdiff(unique(data$pid), flaggedPatients)
      totalUnflaggedPatients = length(unflaggedPatients)
      
      # Create list of flagged test results - take the first flagged test for each patient
      flaggedResults = data[which(data$outlier == TRUE), ]
      flaggedResults = flaggedResults[order(flaggedResults[, 2]), ]
      flaggedResults = flaggedResults[!(duplicated(flaggedResults[, 1])), ]
      
      if (length(flaggedResults$pid) > 10) {
        # Find all ICD9 codes for patients with flagged test results, before the date of this first flagged test
        ICD9s = sapply(flaggedPatients, FindICD9s, flaggedResults)
        haveICD9s = FALSE
        if (length(ICD9s) != 0) {
          ICD9table = as.data.frame(table(unlist(ICD9s)), useNA = 'no')
          ICD9table = ICD9table[order(ICD9table[, 2], decreasing = TRUE), ]
          haveICD9s = TRUE
        }
        
        # Create strings listing all diseases and drugs that are significantly overrepresented in out of range patients.
        # Significant overrepresentation is considered to be present if the p value from the Fisher's exact test is less than criticalP
        if (haveICD9s) {
          # Create contingency table for the relationship between a disease and flagged test result.
          # Perform Fisher's exact test on this table
          # Only perform this analysis for diseases that are present in a given proportion of flagged patients (criticalProp)
          limit = which(ICD9table[, 2] <= ceiling(totalFlaggedPatients * criticalProp))[1] - 1
          if (is.na(limit)) {
            limit = length(ICD9table[, 2])
          }
          fisherTestICD9 = sapply(ICD9table[(1:limit), 1], PerformFishertestICD9, ICD9table, totalFlaggedPatients, unflaggedPatients)
          fisherTestICD9 = p.adjust(fisherTestICD9, method = 'bonferroni')
          
          DOI = as.character(ICD9table[which.min(fisherTestICD9), 1])
          
          pvalue = min(fisherTestICD9)
          if (pvalue > criticalP) {
            converged = TRUE
            exclude1 = numeric(0)
          } else {
            # Find all patients who have the significant ICD9 codes
            exclude1 = FindExclusions(DOI)
            exclusionCounts = c(exclusionCounts, length(which(data$pid %in% unique(exclude1))))
            exclusionII = c(exclusionII, ii)
            excludedICD9s = c(excludedICD9s, DOI)
            exclusionPval = c(exclusionPval, pvalue)
          }
          
        } else {
          exclude1 = numeric(0)
        }
       
        # Create a list of all patients with either significant diseases or drugs
        excludePatients = unique(exclude1)
        includePatients = setdiff(unique(data$pid), excludePatients)
        
        # Remove excluded patients from data base
        data = data[which(data$pid %in% includePatients), ]
        
      } else {
        
        excludePatients = numeric(0)
        converged = TRUE
        
      }
      
    } else {
      converged = TRUE
    }
    
  }
  
  print(as.numeric(quantile(as.numeric(data$ord_num), c(0.025, 0.05, 0.95, 0.975), na.rm = TRUE)))
  print(length(unique(data$pid)))
  
  results[ii, 1:2] = as.numeric(quantile(as.numeric(data$ord_num), c(0.025, 0.975), na.rm = TRUE))
  results[ii, 3] = length(unique(data$pid))
  
  save(data, file = paste('HGB_data_remaining_', ii, '.Rdata', sep = ''))
}

# Create objects to save results
ICD9_names = sapply(unlist(excludedICD9s), getICD9Names)
outputTable = data.frame(category = unlist(exclusionII), icd9 = unlist(excludedICD9s), pvalue = unlist(exclusionPval), count = unlist(exclusionCounts), name = unlist(ICD9_names))

# Save remaining results, and entire workspace
save(results, file = paste(saving, '_results.Rdata', sep = ""))
save(list = ls(all = TRUE), file = paste(saving, '_all.Rdata', sep = ""))

# Append excluded ICD9s to output file
write.table(saving, file = 'ExcludedICD9s.csv', sep = ',', eol = '\r', append = TRUE, row.names = FALSE)
write.table(outputTable, file = 'ExcludedICD9s.csv', sep = ',', eol = '\r', append = TRUE, row.names = FALSE)

