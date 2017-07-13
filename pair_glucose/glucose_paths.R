#analysisType = "gluc1mo"
analysisType = "gluc4yr"

#The base base path
basicPath='/scratch/leeschro_armis/patnatha/'
prepare_paired_glucoses_path=paste(basicPath, "prepared_data/", sep="")

# The input directory where to do basic analysis
if(analysisType == "gluc1mo"){
    inputDir=paste(basicPath, 'glucose_1_month/', sep="")
    prepare_paired_glucoses_path=paste(prepare_paired_glucoses_path, 
        '1mo_paired_glucoses.Rdata', sep="")
} else if(analysisType == "gluc4yr"){
    inputDir=paste(basicPath, 'glucose_4_years/', sep="")
    prepare_paired_glucoses_path=paste(prepare_paired_glucoses_path, 
        '4yr_paired_glucoses.Rdata', sep="")
}

print(paste("inputDir", inputDir, sep="|"))
print(paste("prepare_paired_glucoses_path", prepare_paired_glucoses_path, sep="|"))

# The output directory for slicing up for the pairing algorithm
paired_pieces_output=paste(inputDir, "paired_pieces/", sep="")
print(paste("paired_pieces_output", paired_pieces_output, sep="|"))

# The output file of the paired glucose values
paired_glucoses_path=paste(inputDir, 'paired_glucoses.Rdata', sep="")
print(paste("paired_glucoses_path", paired_glucoses_path, sep="|"))


