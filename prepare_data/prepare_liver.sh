source ../basedir.sh

#Set the output directory
outdir="${preparedir}liver_5_years/"
mkdir -p $outdir

#Set basic variables
incGrp="outpatient_and_never_inpatient"
therace="all"
theage="adult"

#RUN ALT
indir="alt_5_years"
thesex="both"
run_em_prepare

#RUN AST
indir="ast_5_years"
thesex="both"
run_em_prepare

#Run GGTP
indir="ggtp_5_years"
thesex="male"
run_em_prepare

indir="ggtp_5_years"
thesex="female"
run_em_prepare

