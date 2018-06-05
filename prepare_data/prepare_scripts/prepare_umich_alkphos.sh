pushd ../
source ../basedir.sh
toswitch="ALK_UMICH"
switch_input

#Set basic variables
incGrp="outpatient"
therace="all"
inval="ALK"

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=16gb/' prepare_data.pbs
thesex="both"

theage="0D_365D"
run_em_prepare

theage="1Y_10Y"
run_em_prepare

theage="10Y_17Y"
run_em_prepare

theage="17Y_150Y"
run_em_prepare

popd
