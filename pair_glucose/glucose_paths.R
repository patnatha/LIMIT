analysisType = "gluc2mo"
#analysisType = "gluc5yr"

#The base base path
basicPath='/scratch/leeschro_armis/patnatha/'
prepare_paired_glucoses_path=paste(basicPath, "prepared_data/", sep="")

# The input directory where to do basic analysis
if(analysisType == "gluc2mo"){
    inputDir=paste(basicPath, 'glucose_2_months/', sep="")
    prepare_paired_glucoses_path=paste(prepare_paired_glucoses_path, 
        '2mo_paired_glucoses.Rdata', sep="")
} else if(analysisType == "gluc5yr"){
    inputDir=paste(basicPath, 'glucose_5_years/', sep="")
    prepare_paired_glucoses_path=paste(prepare_paired_glucoses_path, 
        '5yr_paired_glucoses.Rdata', sep="")
}

print(paste("inputDir", inputDir, sep="|"))
print(paste("prepare_paired_glucoses_path", prepare_paired_glucoses_path, sep="|"))

# The output directory for slicing up for the pairing algorithm
paired_pieces_output=paste(inputDir, "paired_pieces/", sep="")
print(paste("paired_pieces_output", paired_pieces_output, sep="|"))

# The output file of the paired glucose values
paired_glucoses_path=paste(inputDir, 'paired_glucoses.Rdata', sep="")
print(paste("paired_glucoses_path", paired_glucoses_path, sep="|"))


