pushd ../
source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

toswitch="TUNE_CALIPER_ANALYZE"
switch_input

run_male_female(){
    thesex="male"
    run_em_prepare
    thesex="female"
    run_em_prepare
}

startDate="2013-01-01"
endDate="2018-01-01"
therace="all"

run_all(){
    inval="IRON"
    theage="14Y_19Y"
    run_male_female

    inval="PHOS"
    theage="0D_15D"
    run_male_female
    theage="15D_365D"
    run_male_female
    theage="1Y_5Y"
    run_male_female
    theage="13Y_16Y"
    run_male_female
    theage="16Y_19Y"
    run_male_female

    inval="URIC"
    theage="0D_15D"
    run_male_female
    theage="1Y_12Y"
    run_male_female
    theage="12Y_19Y"
    run_male_female

    inval="ALT"
    theage="13Y_19Y"
    run_male_female

    inval="AST"
    theage="0D_15D"
    run_male_female
    theage="7Y_12Y"
    run_male_female
    theage="12Y_19Y"
    run_male_female

    inval="LDH"
    theage="15D_365D"
    run_male_female
    theage="1Y_10Y"
    run_male_female
    theage="10Y_15Y"
    run_male_female
    theage="15Y_19Y"
    run_male_female

    inval="APOB"
    theage="1Y_6Y"
    run_male_female

    inval="CHOL"
    theage="0D_15D"
    run_male_female
    theage="15D_365D"
    run_male_female
    theage="1Y_19Y"
    run_male_female

    inval="TRIG"
    theage="0D_15D"
    run_male_female

    inval="ALB"
    run_male_female
    theage="8Y_15Y"
    run_male_female
    theage="15Y_19Y"
    run_male_female

    inval="C3"
    theage="0D_15D"
    run_male_female
    theage="1Y_19Y"
    run_male_female

    inval="C4"
    theage="1Y_19Y"
    run_male_female

    inval="HPT"
    theage="15D_365D"
    run_male_female
    theage="12Y_19Y"
    run_male_female

    inval="IGA"
    theage="0Y_1Y"
    run_male_female

    inval="IGG"
    theage="4Y_10Y"
    run_male_female

    inval="IGM"
    theage="1Y_19Y"
    run_male_female

    inval="PAB"
    theage="15D_365D"
    run_male_female
    theage="1Y_5Y"
    run_male_female
    theage="5Y_13Y"
    run_male_female
    theage="13Y_16Y"
    run_male_female
    theage="16Y_19Y"
    run_male_female

    inval="PROT"
    theage="0D_15D"
    run_male_female
    theage="1Y_6Y"
    run_male_female

    inval="TSF"
    theage="0D_63D" #9 weeks => 63 days
    run_male_female
    theage="63D_365D"
    run_male_female
}

incGrp="all"
run_all
incGrp="outpatient"
run_all
incGrp="outpatient_and_never_inpatient"
run_all

popd
