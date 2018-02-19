pushd ../
source ../basedir.sh
toswitch="BMP"
switch_input

sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

#Set the include grp
incGrp="outpatient_and_never_inpatient"

#Set the bmp for all adults
thesex="both"
therace="all"
theage="adult"

inval="CHLOR"
run_em_prepare
inval="CO2"
run_em_prepare
inval="POT"
run_em_prepare
inval="SOD"
run_em_prepare

inval="UN"
thesex="male"
run_em_prepare
thesex="female"
run_em_prepare

inval="CREAT"
thesex="male"
run_em_prepare
thesex="female"
run_em_prepare
popd

