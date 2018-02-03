source ../basedir.sh

#Set the output directory
outdir="${preparedir}glucose_2_months/"
mkdir -p $outdir

#Set basic variables
incGrp="inpatient"
therace="all"
thesex="both"
inval="GLUC,GLUC-WB"
theage="adult"
startDate="2015-01-01"
endDate="2015-03-01"
runInPlace="TRUE"

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs
run_em_prepare

