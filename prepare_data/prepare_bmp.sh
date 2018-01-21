source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=44gb/' prepare_data.pbs

#Set the output directory
outdir="${preparedir}basic_metabolic_panel/"
mkdir -p $outdir

#Set the include grp
incGrp="outpatient_and_never_inpatient"

#Set the bmp for all adults
thesex="both"
therace="all"
theage="adult"

inval="UN"
run_em_prepare
inval="CHLOR"
run_em_prepare
inval="CO2"
run_em_prepare
inval="CREAT"
run_em_prepare
inval="POT,POTPL"
run_em_prepare
inval="SOD"
run_em_prepare

