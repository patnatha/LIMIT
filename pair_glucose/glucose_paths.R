#The base base path
basicPath='/scratch/leeschro_armis/patnatha/'

# The input directory where to do basic analysis
inputDir=paste(basicPath, 'glucose_3_month/', sep="")

# The output file of the paired glucose values
paired_glucoses=paste(inputDir, 'paired_glucoses.Rdata', sep="")

# The output of the prepared data
prepare_paired_glucoses=paste(basicPath, 'prepared_data/prepared_paired_glucoses.Rdata', sep="")

