source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=32gb/' prepare_data.pbs

#Set the output directory
outdir="${preparedir}liver_enzymes/"
mkdir -p $outdir

#Set basic variables
incGrp="outpatient_and_never_inpatient"
therace="all"

#RUN ALT
inval="ALT"
thesex="both"
theage="adult"
run_em_prepare

#RUN AST
inval="AST"
thesex="both"
theage="0Y_1Y"
run_em_prepare
theage="1Y_12Y"
run_em_prepare
theage="12Y_150Y"
run_em_prepare

#Run GGTP
inval="GGTP"
theage="adult"
thesex="male"
run_em_prepare
thesex="female"
run_em_prepare

