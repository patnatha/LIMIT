source ../basedir.sh
toswitch="TEST"
switch_input

#Set basic variables
incGrp="inpatient"
therace="all"
thesex="both"
inval="GLUC,GLUC-WB"
theage="adult"
startDate="2015-01-01"
endDate="2015-03-01"

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' prepare_data.pbs
run_em_prepare

