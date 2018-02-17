source ../basedir.sh
toswitch="BILI"
switch_input

#Set basic variables
incGrp="outpatient"
therace="all"
thesex="both"

#RUN TBILI
sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs
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

