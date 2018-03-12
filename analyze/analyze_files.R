library(dplyr)
library(optparse)
library(stringr)
source('../import_files.R')
source('analyze_helper.R')

outniCuts = 3500 
#outniCuts = seq(250, 10000, by=250)
outCuts = 1500 
#outCuts = seq(250, 10000, by=250)
allCut = 0

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata"),
  make_option("--type", type="character", default="combined", help="file type to load") 
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)

#Load input data
input_dir = args[['input']]
print(paste("INPUT: ", input_dir, sep=""))
if(is.na(input_dir)){
    stop()
}

resultType= args[['type']]
if(resultType != "combined" && resultType != "joined"){
    stop()
}

#Create output file
searchName = paste("analysis_results_", resultType,".csv", sep="")
output_file = paste(str_replace(input_dir," ",""), searchName, sep="/")

files=list.files(input_dir, pattern = searchName, full.names = TRUE,  recursive=T)
for(file in files){
    if(length(grep("/all/random", file)) != 0){
        allTable = tbl_df(read.csv(file=file, header=TRUE, sep=","))
    } else if(length(grep("/outpatient/random", file)) != 0){
        outTable = tbl_df(read.csv(file=file, header=TRUE, sep=","))
    } else if(length(grep("/outpatient_and_never_inpatient/random", file)) != 0){
        outniTable = tbl_df(read.csv(file=file, header=TRUE, sep=","))
    }  
}

for(outniCut in outniCuts){
    for(outCut in outCuts){
        tempAllTable = allTable %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Pre.LIMIT.Count)
        tempAllTable = tempAllTable %>% rename(AllPreLimitCnt = Pre.LIMIT.Count)

        tempOutTable = outTable  %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Pre.LIMIT.Count)
        tempOutTable = tempOutTable %>% filter(Pre.LIMIT.Count >= allCut) %>% rename(OutPreLimitCnt = Pre.LIMIT.Count)

        tempOutniTable = outniTable %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection, LIMIT.Params, Pre.LIMIT.Count)
        tempOutniTable = tempOutniTable %>% filter(Pre.LIMIT.Count >= allCut) %>% rename(OutniPreLimitCnt = Pre.LIMIT.Count)

        joinedTable = inner_join(tempOutniTable, inner_join(tempAllTable, tempOutTable))

        #Get all the valid outpatient_and_never_inpatient values
        outNiValid = joinedTable %>% filter(OutniPreLimitCnt >= outniCut) %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection)

        #Get all the valid outpatient values
        outValid = joinedTable %>% filter(OutPreLimitCnt >= outCut & OutPreLimitCnt < outniCut) %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection)

        #Combine the out_ni and out tables
        out_outni_table = union(outNiValid, outValid)

        #Get the rest of the values as all
        allValid = anti_join(joinedTable, out_outni_table) %>% select(Result.Code, Sex, Race, Start.Days, End.Days, Selection)

        #Build compliation table
        finalResult = union(inner_join(outValid, outTable), inner_join(outNiValid, outniTable))
        finalResult = union(finalResult, inner_join(allValid, allTable))

        #Sum up the lower limit in CI
        getLimitRatio = as.numeric(finalResult$Low.in.CI, na.rm=TRUE)
        totalSum = 0
        denominator = 0
        for(x in getLimitRatio){
            if(!is.na(x) && x != "NA"){
                totalSum = totalSum + x
                denominator = denominator + 1
            }
        }

        #SUm u pthe upper limit in CI
        getLimitRatio = as.numeric(finalResult$High.in.CI, na.rm=TRUE)
        for(x in getLimitRatio){
            if(!is.na(x) && x != "NA"){
                totalSum = totalSum + x
                denominator = denominator + 1
            }
        }

        print(paste(totalSum, "/", denominator, ":SUM:", outniCut, ",", outCut, ",", allCut, sep=""))
    }
}

print(paste("SAVING: ", output_file, sep=""))
write.csv(finalResult %>% arrange(File), file=output_file, quote=F, row.names=F)

