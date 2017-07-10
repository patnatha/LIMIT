library(BBmisc)

# Bin pack algorithm
binPack = function(x, capacity) {
  #assertNumeric(x, min.len = 1L, lower = 0, any.missing = FALSE)
  #assertNumber(capacity)

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

#The dirsource('glucose_paths.R')ectory from which to read
source('glucose_paths.R')

#Create the output directory
if(dir.exists(paired_pieces_output)){
    unlink(paired_pieces_output, recursive = TRUE)
}
dir.create(paired_pieces_output)

# Import the data
source("../import_files.R")
glucoseVals = import_lab_values(inputDir)

#Pick out the columns that we need for analyzing
selected_glucoses = select(glucoseVals, one_of(c('PatientID', 'ACCESSION_NUMBER', 'COLLECTION_DATE', 'RESULT_CODE', 'VALUE')))

#Get a count of the largest bin
pidCnt = selected_glucoses %>% group_by(PatientID) %>% count() %>% filter(n > 1) 
maxPtCnt = pidCnt %>% select(n) %>% max()
if(maxPtCnt < 100000){
    maxPtCnt = 100000
}

# Pack the bins using a greedy algorithm
packedBins = binPack(pidCnt$n, maxPtCnt)
splitBins = split(pidCnt$n, packedBins)

#Iterate over all the bins
binCounter = 1
usedPids = c(character())
for(bin in splitBins){
    # Create a bin to fill with data
    curBinSize = sum(bin)
    print(paste("Binning (",as.character(curBinSize), "): ", as.character(binCounter), '/', as.character(length(splitBins)), sep=""))
    binData = data.frame()

    # Get all the data and fill the bin
    for(count in bin){
        foundBin = pidCnt %>% filter(n == count) %>% filter(!PatientID %in% usedPids) %>% first()
        if(!is.na(foundBin[[1,1]])){
            #For a pid get all the records
            binPid = foundBin[[1,1]]
            records = selected_glucoses %>% filter(PatientID == binPid)

            #Append the data to the output bin
            binData = rbind(binData, records)

            #Keep track of the PIDs already used
            usedPids = rbind(usedPids, binPid)
        }
    }

    #Save the output file
    save(binData, file=paste(paired_pieces_output, as.character(binCounter), ".bin", sep=""))
    binCounter = binCounter + 1 
}

