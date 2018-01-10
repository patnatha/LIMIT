source ../basedir.sh

#Set the output directory
outdir="${preparedir}basic_metabolic_panel/"
mkdir -p $outdir

#Set the include grp
incGrp="outpatient_and_never_inpatient"

#Set the bmp for all adults
thesex="both"
therace="all"
theage="adult"

indir="bun_5_years"
run_em_prepare
indir="chloride_5_years"
run_em_prepare
indir="co2_5_years"
run_em_prepare
indir="creatinine_5_years"
run_em_prepare
indir="potassium_5_years"
run_em_prepare
indir="sodium_5_years"
run_em_prepare

