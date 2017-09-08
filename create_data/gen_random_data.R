#Default directory to save things
saving = ''

#Load up the data from command line argument
library(optparse)
option_list <- list(
    make_option("--output", type="character", default="/scratch/leeschro_armis/patnatha/prepared_data/", help="directory to put results")
)

#Parse the incoming options
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

#Parse the output directory and build the output file path
saving = paste(args[['output']], 'rand_data.Rdata', sep="/")
saving = gsub('//', '/', saving)

normal_dist_lab_values = function(patientDemo, labObs, mean, sd)
{
  #Create lab values table
  l_val<-rnorm(labObs, mean=mean, sd=sd)
  
  #Add random pids to these lab values
  pid<-sample(patientDemo$pid, replace = TRUE, labObs)
  
  #Create the dataframe
  labValues<-data.frame(pid, l_val)
  labValues$l_date = rep(as.Date(1900/01/01, origin = '1970-01-01'),length(labValues$l_val))
  labValues$timeOffset = rep(0,length(labValues$l_val))
  
  #Create a timestamp for each lab val
  for(i in 1:nrow(labValues))
  { 
    pbday<-patientDemo[which(patientDemo$pid == labValues[i,]$pid),]$bday
    labValues[i,]$l_date<-sample(seq.Date(pbday, as.Date('2017-01-01'), by="day"), 1)
    labValues[i,]$timeOffset<-as.numeric(labValues[i,]$l_date - pbday)

    if(i %% 1000 == 0){
      print(paste(as.character(i), '/', as.character(nrow(labValues)), sep=""))
    }
  }
  return (labValues)
}

create_icd_values = function(patientDemo, numICDperPt)
{
  #Count number of uniqPatients
  uniqPat = nrow(patientDemo)
  
  #Create a list of random ICDs
  icd<-sample(1:round(uniqPat/5, digits = 0), 
              round(uniqPat * numICDperPt, digits = 0), replace=TRUE)
  icd_name = icd

  #Add a random pid to these ICD values
  pid=sample(patientDemo$pid, replace = TRUE, length(icd))
  
  #Create the data frame
  icdValues<-data.frame(pid, icd, icd_name)
  icdValues$icd_date = rep(as.Date(1900/01/01, origin = '1970-01-01'),length(icdValues$icd))
  icdValues$timeOffset = rep(0,length(icdValues$icd))
  
  #Create a timestamp for each ICD code
  for(i in 1:nrow(icdValues))
  {
    pbday<-patientDemo[which(patientDemo$pid == icdValues[i,]$pid),]$bday
    icdValues[i,]$icd_date=sample(seq.Date(pbday, as.Date('2017-01-01'), by="day"), 1)
    icdValues[i,]$timeOffset<-as.numeric(icdValues[i,]$icd_date - pbday)
    if(i %% 1000 == 0){
      print(paste(as.character(i), '/', as.character(nrow(icdValues)), sep=""))
    }
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

over_sat_icd_values = function(the_bad_lab_vals, allIcdValues, icdsubset)
{
  # Grab a sample of ten ICDs to over saturate
  icds=sample(allIcdValues$icd, icdsubset)

  # Print out the icds that you are going to over saturate
  print("====BAD ICDS====")
  print(icds)
  print("================")

  # Calculate how many times to over saturate
  theLim = nrow(the_bad_lab_vals)
  propLim = round(nrow(allIcdValues)/10, digits = 0)
  if(propLim < theLim){
     theLim = propLim
  }

  # OVer saturate
  for(i in 1:theLim){
    #Get a lab value information
    pid = the_bad_lab_vals[i,]$pid
    icd_date = the_bad_lab_vals[i,]$l_date
    timeOffset = the_bad_lab_vals[i,]$timeOffset

    #Get a random icd from the subset
    icd = sample(icds, 1)
    icd_name = icd
  
    #Append the new ICDs to the current table  
    allIcdValues = rbind(allIcdValues, data.frame(pid, icd, icd_name, icd_date, timeOffset))
  }
  
  return(allIcdValues)
}

#Create a base number of patients
number_of_patients = 1000

#Create list of unique patient ids
print("Creating Patients")
patientDemo = create_patients(number_of_patients)
print("Created Patients")

#Create a list of random associated ICD codes
print("Add ICD values")
icdValues = create_icd_values(patientDemo, 10)
print("Added ICD values")

#Create some normally distributed lab observations
print("Create Normal Lab Values")
normal_lab_vals = normal_dist_lab_values(patientDemo, 10000, 12, 2)
print("Created Normal Lab Values")

#Create some more normally distributed lab observations
print("Create Bad Lab Values")
bad_lab_vals = normal_dist_lab_values(patientDemo, 500, 20, 2)
print("Created Bad Lab Values")

#Over saturate a set of lab values with small selection of icds values
print("Oversaturate Bad Lab Values")
icdValues = over_sat_icd_values(bad_lab_vals, icdValues, 10)
print("Oversaturated Bad Lab Values")

#combine all the lab values
labValues = rbind((normal_lab_vals), (bad_lab_vals))
remove(normal_lab_vals, bad_lab_vals)

#Save values to disk
save(patientDemo, icdValues, labValues, file=saving)

