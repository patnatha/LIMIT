#Set the input data
basedir="/scratch/leeschro_armis/patnatha/"
rawfile=`basename ${basedir}`

#Set the output directory
outdir="/scratch/leeschro_armis/patnatha/prepared_data/basic_metabolic_panel/"
mkdir -p $outdir

#Set the function
run_grp(){
    eval "qsub prepare_data.pbs -F \"--input $basedir$indir --sex $thesex --race $therace --include $incGrp --age $theage --output ${outdir}\""
}

#Set the include grp
incGrp="outpatient_and_never_inpatient"

#Set the bmp for all adults
thesex="both"
therace="all"
theage="adult"
indir="bun_5_years"
run_grp
indir="calcium_5_years"
run_grp
indir="chloride_5_years"
run_grp
indir="co2_5_years"
run_grp
indir="creatinine_5_years"
run_grp
indir="potassium_5_years"
run_grp
indir="sodium_5_years"
run_grp

