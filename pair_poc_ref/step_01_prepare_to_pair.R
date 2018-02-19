library(BBmisc)
library(stringr)
source("../import_files.R")
source('paired_paths.R')
source('../prepare_data/prepare_helper.R')

# Bin pack algorithm
binPack = function(x, capacity) {
  too.big = which.first(x > capacity, use.names = FALSE)
  if (length(too.big))
    stopf("Capacity not sufficient. Item %i (x=%f) does not fit", too.big, x[too.big])
  if (any(is.infinite(x)))
    stop("Infinite elements found in 'x'")

  ord = order(x, decreasing = TRUE)
  grp = integer(length(x))
  sums = vector(typeof(x), 1L)
  bin.count = 1L

  for(j in ord) {
    new.sums = sums + x[j]
    pos = which.first(new.sums <= capacity, use.names = FALSE)
    if (length(pos)) {
      grp[j] = pos
      sums[pos] = new.sums[pos]
    } else {
      bin.count = bin.count + 1L
      grp[j] = bin.count
      sums[bin.count] = x[j]
    }
  }
  grp
}

#Parse the incoming command line arguments
cmdLineArgs = prepare_parse_args()
input_val = attr(cmdLineArgs, "input")
startDate = attr(cmdLineArgs, "start")
endDate = attr(cmdLineArgs, "end")
output_filename = attr(cmdLineArgs, "name")

#Create the output sub-directory
paired_pieces_output=paired_pieces_path(dirname(output_filename))
if(dir.exists(paired_pieces_output)){
    unlink(paired_pieces_output, recursive = TRUE)
}
dir.create(paired_pieces_output)

# Import the Lab Values dataa
labValues = import_lab_values(input_val, startDate, endDate)

# Load the patient info
patient_bday = import_patient_bday(labValues$PatientID)

# Process the lab values to filter for queried results
processedResult = process_lab_values(labValues, patient_bday, cmdLineArgs)
labValues = attr(processedResult, "labValues")
remove(processedResult)

# Save the raw data to the output directory
parameters<-1:1
attr(parameters, "resultCode") = input_val
attr(parameters, "resultStart") = as.Date(as.POSIXlt(startDate * 86400, origin="1970-01-01"))
attr(parameters, "resultEnd") = as.Date(as.POSIXlt(endDate * 86400, origin="1970-01-01"))
attr(parameters, "race") = attr(cmdLineArgs, "race")
attr(parameters, "age") = attr(cmdLineArgs, "age")
attr(parameters, "sex") = attr(cmdLineArgs, "sex")
attr(parameters, "group") = attr(cmdLineArgs, "include")
attr(parameters, "name") = output_filename
originalDataFilePath=paste(paired_pieces_output, basename(output_filename), sep="/")
labValuesLength = nrow(labValues)
save(labValuesLength, parameters, file=originalDataFilePath)

#Get a count of the largest bin
pidCnt = labValues %>% group_by(PatientID) %>% count() %>% filter(n > 1) %>% as.data.frame()
maxPtCnt = max(pidCnt$n)
if(maxPtCnt < 100000){
    maxPtCnt = 100000
}

# Pack the bins using a greedy algorithm
packedBins = binPack(pidCnt$n, maxPtCnt)
splitBins = split(pidCnt$n, packedBins)

newSplitBins = list()
for(bin in splitBins){
    # Get frequency of bins occurences
    binCnts = table(bin)
    tmpBinList = list()

    #Iterate over all these frequencies
    for(cntName in names(binCnts)){
        #Get the Pids with this many bins
        foundBin =  tibble::rownames_to_column(pidCnt) %>%
                    filter(n == as.numeric(cntName)) %>% 
                    head(binCnts[[cntName]])
        
        if(nrow(foundBin) > 0){
            for(pid in foundBin$PatientID){
                tmpBinList[[length(tmpBinList)+1]] = pid
            }
           
            # Remove the used Pids
            pidCnt = pidCnt[-(as.integer(foundBin$rowname)),]
        }
    }

    #update the bins
    newSplitBins[[length(newSplitBins)+1]] = tmpBinList
}

#Iterate over all the bins
binCounter = 1
for(bin in newSplitBins){
    # Get all the records
    records = labValues %>% filter(PatientID %in% bin)

    # Create a bin to fill with data
    print(paste("Binning (", as.character(nrow(records)), "): ", as.character(binCounter), '/', as.character(length(splitBins)), sep=""))

    #Save the output file
    save(records, originalDataFilePath, file=paste(paired_pieces_output, as.character(binCounter), ".bin", sep=""))
    binCounter = binCounter + 1
}

