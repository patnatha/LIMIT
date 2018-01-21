source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=44gb/' prepare_data.pbs

#Set the output directory
outdir="${preparedir}liver_enzymes/"
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

