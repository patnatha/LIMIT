source ../basedir.sh

#Set the output directory
outdir="${preparedir}bilirubin_5_years/"
mkdir -p $outdir

#Set basic variables
therace="all"
thesex="both"

#RUN DBILI
incGrp="all"
theage="all"
indir="direct_bilirubin_5_years"
run_em_prepare

#RUN TBILI 
incGrp="all"
indir="total_bilirubin_5_years"
theage="0D_30D"
run_em_prepare

theage="1Y_11Y"
run_em_prepare

theage="12Y_150Y"
run_em_prepare

