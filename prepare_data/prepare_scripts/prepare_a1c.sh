source ../basedir.sh
toswitch="A1C"
switch_input

sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

#Set basic variables
inval="HGB A1C"  
inval="A1C"
incGrp="outpatient"
therace="all"
thesex="both"
theage="adult"
run_em_prepare

