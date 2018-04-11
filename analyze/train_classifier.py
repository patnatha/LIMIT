library(dplyr)
library(optparse)
library(stringr)
library(naivebayes)
source('../import_files.R')
source('analyze_helper.R')

outniCuts = 1400
#outniCuts = seq(0, 2000, by=100)
outCuts = 1400 
#outCuts = seq(0, 2000, by=100)
allCuts = 0
#allCuts = seq(0, 3000, by=100)

whichCnt = "PRE" #"HORN"

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata"),
  make_option("--type", type="character", default="combined", help="file type to load") 
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

input_dir = args[['input']]
print(paste("INPUT: ", input_dir, sep=""))
if(is.na(input_dir)){
    stop()
}

resultType= args[['type']]
if(resultType != "combined" && resultType != "joined"){
    stop()
}

searchName = paste("analysis_results_", resultType,".csv", sep="")
output_file = paste(str_replace(input_dir," ",""), searchName, sep="/")

files=list.files(input_dir, pattern = searchName, full.names = TRUE,  recursive=T)
for(file in files){
    if(length(grep("/all/random", file)) != 0){
        allTable = tbl_df(read.csv(file=file, header=TRUE, sep=","))
    } else if(length(grep("/outpatient/random", file)) != 0){
        outTable = tbl_df(read.csv(file=file, header=TRUE, sep=","))
        outLimits = tbl_df(read.csv(file=str_replace(file, searchName,"limit_excludes.csv"), header=TRUE, sep=","))
    } else if(length(grep("/outpatient_and_never_inpatient/random", file)) != 0){
        outniTable = tbl_df(read.csv(file=file, header=TRUE, sep=","))
    } 
}

icdCnt=outLimits %>% filter(type == "icd") %>% group_by(input) %>% summarise(icd_sum=sum(excluded.lab.count))
medCnt=outLimits %>% filter(type == "med") %>% group_by(input) %>% summarise(med_sum=sum(excluded.lab.count))
labCnt=outLimits %>% filter(type == "lab") %>% group_by(input) %>% summarise(lab_sum=sum(excluded.lab.count))
outLimits = full_join(icdCnt, full_join(medCnt, labCnt))

outLimits$input = str_replace(outLimits$input, "_joined.Rdata","")
outTable$File = str_replace(outTable$File, "_combined.Rdata", "")
combinedTable = full_join(outLimits %>% rename(File = input), outTable)
#glimpse(combinedTable)

lowCITable = combinedTable %>% filter(!is.na(Low.in.CI)) %>% select(icd_sum, med_sum, lab_sum, Pre.LIMIT.Count, LIMIT.ICD.Count, LIMIT.Med.Count, LIMIT.Lab.Count, Joined.Count, Combined.Count, Horn.Count, Low.in.CI)
TrustLowNB=naive_bayes(lowCITable %>% select(-c(Low.in.CI)), lowCITable$Low.in.CI)

highCITable = combinedTable %>% filter(!is.na(High.in.CI)) %>% select(icd_sum, med_sum, lab_sum, Pre.LIMIT.Count, LIMIT.ICD.Count, LIMIT.Med.Count, LIMIT.Lab.Count, Joined.Count, Combined.Count, Horn.Count, High.in.CI)
TrustHighNB=naive_bayes(highCITable %>% select(-c(High.in.CI)), highCITable$High.in.CI)


