#Set the input data
basedir="/scratch/leeschro_armis/patnatha/"
rawfile=`basename ${basedir}`

#Set the output directory
outdir="/scratch/leeschro_armis/patnatha/prepared_data/basic_metabolic_panel/"
mkdir -p $outdir
eval "rm -rf $outdir/*"

#Set the function
run_grp(){
    tempdir=$outdir
    mkdir -p $tempdir
    eval "rm -rf $tempdir/*"
    eval "qsub prepare_data.pbs -F \"--input $basedir$indir --sex $thesex --race $therace --include $incGrp --age $theage --output ${tempdir}\""
}

#Set the include grp
incGrp="outpatient_and_never_inpatient"

#White Male
thesex="male"
therace="white"
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

#White Female
thesex="female"
therace="white"
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

#Black Male
thesex="male"
therace="black"
theage="adult"
ndir="bun_5_years"
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

#Black Female
thesex="female"
therace="black"
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

