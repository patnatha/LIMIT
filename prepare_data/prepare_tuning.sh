source ../basedir.sh
toswitch="TUNEUP"
switch_input

sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

incGrp="outpatient_and_never_inpatient"

inval="HGB"
therace="all"
theage="16Y_140Y"
thesex="male"
run_em_prepare
thesex="female"
run_em_prepare

inval="WBC"
therace="all"
theage="16Y_140Y"
thesex="male"
run_em_prepare
thesex="female"
run_em_prepare


inval="PLT"
therace="all"
thesex="both"
theage="182D_51100D"
run_em_prepare

inval="SOD"
therace="all"
thesex="both"
theage="1Y_140Y"
run_em_prepare

inval="POT"
therace="all"
thesex="both"
theage="1Y_140Y"
run_em_prepare

inval="CHLOR"
therace="all"
theage="18Y_140Y"
thesex="both"
run_em_prepare

inval="C02"
therace="all"
theage="18Y_140Y"
therace="all"
thesex="male"
run_em_prepare
theage="10Y_140Y"
thesex="female"
run_em_prepare

inval="UN"
therace="all"
theage="18Y_140Y"
thesex="male"
run_em_prepare
thesex="female"
run_em_prepare

inval="CREAT"
therace="all"
theage="16Y_140Y"
thesex="male"
run_em_prepare
thesex="female"
run_em_prepare

