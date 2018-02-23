pushd ../
source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

toswitch="TUNE_CALIPER"
switch_input

run_male_female(){
    thesex="male"
    run_em_prepare
    thesex="female"
    run_em_prepare
}

startDate="2013-01-01"
endDate="2018-01-01"

incGrp="outpatient"
#incGrp="inpatient"
therace="all"

inval="ALB"
theage="8Y_15Y"
run_male_female

inval="AST"
theage="12Y_19Y"
run_male_female

inval="CHOL"
theage="1Y_19Y"
run_male_female

popd

