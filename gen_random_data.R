#Default directory to save things
saving = ''

#Load up the data from command line argument
library(optparse)
option_list <- list(
    make_option("--output", type="character", default="tmp", help="directory to put results")
)

#Parse the incoming options
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

#Assign the parsed options to their variables
saving = paste(args[['output']], '/rand_data.Rdata', sep="")

normal_dist_lab_values = function(patientDemo, labObs, mean, sd)
{
  #Create lab values table
  l_vals<-rnorm(labObs, mean=mean, sd=sd)
  
  #Add random pids to these lab values
  pid<-sample(patientDemo$pid, replace = TRUE, labObs)
  
  #Create the dataframe
  labValues<-data.frame(pid, l_vals)
  labValues$l_date = rep(as.Date(1900/01/01, origin = '1970-01-01'),length(labValues$l_vals))
  labValues$timeOffset = rep(0,length(labValues$l_vals))
  
  #Create a timestamp for each lab val
  for(i in 1:nrow(labValues))
  { 
    pbday<-patientDemo[which(patientDemo$pid == labValues[i,]$pid),]$bday
    labValues[i,]$l_date<-sample(seq.Date(pbday, as.Date('2017-01-01'), by="day"), 1)
    labValues[i,]$timeOffset<-as.numeric(labValues[i,]$l_date - pbday)
  }
  return (labValues)
}

create_icd_values = function(patientDemo, numICDperPt)
{
  #Count number of uniqPatients
  uniqPat = nrow(patientDemo)
  
  #Create a list of randome ICDs
  icd<-sample(1:round(uniqPat/5, digits = 0), round(uniqPat * numICDperPt, digits = 0), replace=TRUE)
  
  #Add a random pid to these ICD values
  pid=sample(patientDemo$pid, replace = TRUE, length(icd))
  
  #Create the data frame
  icdValues<-data.frame(pid, icd)
  icdValues$icd_date = rep(as.Date(1900/01/01, origin = '1970-01-01'),length(icdValues$icd))
  icdValues$timeOffset = rep(0,length(icdValues$icd))
  
  #Create a timestamp for each ICD code
  for(i in 1:nrow(icdValues))
  {
    pbday<-patientDemo[which(patientDemo$pid == icdValues[i,]$pid),]$bday
    icdValues[i,]$icd_date=sample(seq.Date(pbday, as.Date('2017-01-01'), by="day"), 1)
    icdValues[i,]$timeOffset<-as.numeric(icdValues[i,]$icd_date - pbday)
  }
  
  return(icdValues)
}

create_patients = function(uniqPat)
{
  bdays<-sample(seq.Date(as.Date('1925/01/01'), as.Date('2014/01/01'), by="day"), replace = TRUE, uniqPat)
  pid<-1:uniqPat
  patientDemo<-data.frame(pid, bdays)
  return(patientDemo)
}

over_sat_icd_values = function(bad_lab_vals, icdValues, icdsubset)
{
  icds=sample(icdValues$icd, icdsubset)

  for(i in 1:round(nrow(icdValues)/10, digits = 0)){
    pid = bad_lab_vals[i,]$pid
    icd_date = bad_lab_vals[i,]$l_date
    timeOffset = 0
    icd = sample(icds, 1)
    icdValues = rbind(icdValues, data.frame(pid, icd, icd_date, timeOffset))
  }
  
  print(icds)
  
  return(icdValues)
}

number_of_patients = 1000

#Create list of unique patient ids
patientDemo = create_patients(number_of_patients)

#Create a list of random associated ICD codes
icdValues = create_icd_values(patientDemo, 2.5)

#Create some normally distributed lab observations
normal_lab_vals = normal_dist_lab_values(patientDemo, 5000, 12, 2)

#Create some more normally distributed lab observations
bad_lab_vals = normal_dist_lab_values(patientDemo, 500, 18, 2)

#Over saturate a set of lab values with small selection of icds values
icdValues = over_sat_icd_values(bad_lab_vals, icdValues, 10)

#combine all the lab values
labValues = rbind((normal_lab_vals), (bad_lab_vals))
remove(normal_lab_vals, bad_lab_vals)

#Save values to disk
save(patientDemo, icdValues, labValues, file="rand_data.Rdata")

