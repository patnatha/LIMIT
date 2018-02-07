source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

#Set the output directory
outdir="${preparedir}bilirubin/"
mkdir -p $outdir

#Set basic variables
incGrp="outpatient"
therace="all"
thesex="both"

#RUN TBILI 
inval="TBIL"
theage="0D_30D"
run_em_prepare
theage="30D_365D"
run_em_prepare
theage="1Y_11Y"
run_em_prepare

sed -i 's/ppn=[0-9]\+/ppn=12/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs
theage="12Y_150Y"
run_em_prepare

#RUN DBILI
theage="all"
inval="DBIL"
run_em_prepare
