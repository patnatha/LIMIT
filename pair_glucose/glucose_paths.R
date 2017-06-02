#The base base path
basicPath='/scratch/leeschro_armis/patnatha/'

# The input directory where to do basic analysis
#inputDir=paste(basicPath, 'glucose_3_years/', sep="")
inputDir=paste(basicPath, 'glucose_1_month/', sep="")

# The output directory for slicing up for the pairing algorithm
paired_pieces_output=paste(inputDir, "paired_pieces/", sep="")

# The output file of the paired glucose values
paired_glucoses=paste(inputDir, 'paired_glucoses.Rdata', sep="")

# The output of the prepared data
prepare_paired_glucoses=paste(basicPath, 'prepared_data/3yr_paired_glucoses.Rdata', sep="")

