pushd ../
source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

toswitch="TEST_CALIPER_ANALYZE"
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
    inval="CAL"
    theage="0Y_1Y"
    run_male_female
    theage="1Y_19Y"
    run_male_female
    
    inval="IRON"
    theage="0Y_14Y"
    run_male_female

    inval="PHOS"
    theage="5Y_13Y"
    run_male_female

    inval="URIC"
    theage="15D_365D"
    run_male_female

    inval="ALT"
    theage="0Y_1Y"
    run_male_female
    theage="1Y_13Y"
    run_male_female

    inval="AMYL"
    theage="0D_15D"
    run_male_female
    theage="15D_91D" #13 weeks => 91 days
    run_male_female
    theage="91D_365D"
    run_male_female
    theage="1Y_19Y"
    run_male_female

    inval="AST"
    theage="15D_365D"
    run_male_female
    theage="1Y_7Y"
    run_male_female

    inval="LDH"
    theage="0D_15D"
    run_male_female

    inval="APOB"
    theage="0D_15D"
    run_male_female
    theage="15D_365D"
    run_male_female
    theage="6Y_19Y"
    run_male_female

    inval="TRIG"
    theage="15D_365D"
    run_male_female
    theage="1Y_19Y"
    run_male_female

    inval="ALB"
    theage="0D_15D"
    run_male_female
    theage="15D_365D"
    run_male_female
    theage="1Y_8Y"
    run_male_female

    inval="C3"
    theage="15D_365D"
    run_male_female

    inval="C4"
    theage="0Y_1Y"
    run_male_female

    inval="HPT"
    theage="0D_15D"
    run_male_female
    theage="1Y_12Y"
    run_male_female

    inval="IGA"
    theage="1Y_3Y"
    run_male_female
    theage="3Y_6Y"
    run_male_female
    theage="6Y_14Y"
    run_male_female
    theage="14Y_19Y"
    run_male_female

    inval="IGG"
    theage="0D_15D"
    run_male_female
    theage="15D_365D"
    run_male_female
    theage="1Y_4Y"
    run_male_female
    theage="10Y_19Y"
    run_male_female

    inval="IGM"
    theage="0D_15D"
    run_male_female
    theage="15D_91D" #13 weeks => 91 days
    run_male_female
    theage="91D_365D"
    run_male_female

    inval="PAB"
    theage="0D_15D"
    run_male_female

    inval="PROT"
    theage="15D_365D"
    run_male_female
    theage="6Y_9Y"
    run_male_female
    theage="9Y_19Y"
    run_male_female

    inval="TSF"
    theage="1Y_19Y"
    run_male_female
}

incGrp="all"
run_all
incGrp="outpatient"
run_all
incGrp="outpatient_and_never_inpatient"
run_all

popd
