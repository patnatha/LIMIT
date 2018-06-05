debug=F
library(optparse)
source('../import_files.R')
source('analyze_helper.R')

#Create the options list
option_list <- list(
  make_option("--input", type="character", default=NA, help="file to load Rdata")
)
parser <- OptionParser(usage="%prog [options] file", option_list=option_list)
args <- parse_args(parser)
inputData = args[['input']]

readData <- read.csv(inputData, header=T)

limitSum = readData %>% group_by(LIMIT.Params) %>% summarise(tsum=sum(LIMIT.Ratio))
limitCnt = readData %>% group_by(LIMIT.Params) %>% count()
finalLimit = inner_join(limitSum, limitCnt)

if(debug){
    glimpse(readData)
}

hinci = readData %>% filter(!is.na(High.in.CI)) %>% group_by(LIMIT.Params) %>% summarise(hsum = sum(High.in.CI)) %>% select(LIMIT.Params, hsum)
if(debug){
    print("HIGH IN CI")
    glimpse(hinci)
}

linci = readData %>% filter(!is.na(Low.in.CI)) %>% group_by(LIMIT.Params) %>% summarise(lsum = sum(Low.in.CI)) %>% select(LIMIT.Params, lsum)
if(debug){
    print("LOW IN CI")
    glimpse(linci)
}

lowaci=(readData %>% group_by(LIMIT.Params) %>% filter(!is.na(Low.in.CI)) %>% count() %>% rename(low.ci.cnt=n))
highaci=(readData %>% group_by(LIMIT.Params) %>% filter(!is.na(High.in.CI)) %>% count() %>% rename(high.ci.cnt=n))

summedSum = inner_join(hinci, linci) %>% mutate(tsum = lsum + hsum)
summedSum = inner_join(summedSum, limitCnt)
summedSum = inner_join(summedSum, lowaci)
summedSum = inner_join(summedSum, highaci)
summedSum = summedSum %>% mutate(percentage = as.numeric(lsum + hsum) / as.numeric(low.ci.cnt + high.ci.cnt))

write.csv(summedSum, file="./processed_results.csv", quote=F, row.names=F)

