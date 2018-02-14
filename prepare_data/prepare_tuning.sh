source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

toswitch="TUNEUP"
switch_input

run_male_female(){
    thesex="male"
    run_em_prepare
    thesex="female"
    run_em_prepare
}

startDate="2013-01-01"
endDate="2017-01-01"

incGrp="outpatient"
therace="all"

inval="LDH"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
theage="1Y_10Y"
run_male_female
theage="10Y_15Y"
run_male_female
theage="15Y_19Y"
run_male_female

inval="PAB"
theage="0D_15D"
run_male_female
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

inval="T PROTEIN"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
theage="1Y_6Y"
run_male_female
theage="6Y_9Y"
run_male_female
theage="9Y_19Y"
run_male_female

inval="URIC"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
theage="1Y_12Y"
run_male_female
theage="12Y_19Y"
run_male_female

inval="HPT"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
theage="1Y_12Y"
run_male_female
theage="12Y_19Y"
run_male_female

inval="IGM"
theage="0D_15D"
run_male_female
theage="15D_91D" #13 weeks => 91 days
run_male_female
theage="91D_365D"
run_male_female
theage="1Y_19Y"
run_male_female

inval="DBIL"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
theage="1Y_9Y"
run_male_female
theage="9Y_13Y"
run_male_female
theage="13Y_19Y"
run_male_female

inval="PHOS"
theage="0D_15D"
run_male_female
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

inval="LIP"
theage="0Y_19Y"
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

