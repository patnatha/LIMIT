pushd ../
source ../basedir.sh
toswitch="TEST_CALIPER"
switch_input

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

run_male_female(){
    thesex="male"
    run_em_prepare
    thesex="female"
    run_em_prepare
}

#Set basic variables
#incGrp="all"
#incGrp="outpatient"
incGrp="outpatient_and_never_inpatient"

therace="all"
startDate="2013-01-01"
endDate="2018-01-01"

#Run Calcium
inval="CAL"
theage="0Y_1Y"
run_male_female
theage="1Y_19Y"
run_male_female

#Run Iron
inval="IRON"
theage="0Y_14Y"
run_male_female
#theage="14Y_19Y"
#run_male_female

#Phosphate
inval="PHOS"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
theage="1Y_5Y"
run_male_female
theage="5Y_13Y"
run_male_female
#theage="13Y_16Y"
#run_male_female
#theage="16Y_19Y"
#run_male_female

#Uric Acid
inval="URIC"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
theage="1Y_12Y"
run_male_female
theage="12Y_19Y"
run_male_female

#ALT
inval="ALT"
theage="0Y_1Y"
run_male_female
theage="1Y_13Y"
run_male_female
theage="13Y_19Y"
run_male_female

#Amylase
inval="AMYL"
theage="0D_15D"
run_male_female
theage="15D_91D" #13 weeks => 91 days
run_male_female
theage="91D_365D"
run_male_female
theage="1Y_19Y"
run_male_female

#AST
inval="AST"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
theage="1Y_7Y"
run_male_female
#theage="7Y_12Y"
#run_male_female
#theage="12Y_19Y"
#run_male_female

#LDH
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

#Apo B
inval="APOB"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
theage="1Y_6Y"
run_male_female
theage="6Y_19Y"
run_male_female

#Cholesterol
inval="CHOL"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
#theage="1Y_19Y"
#run_male_female

#Triglyceriades
inval="TRIG"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
theage="1Y_19Y"
run_male_female

#Albumin
inval="ALB"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
theage="1Y_8Y"
run_male_female
#theage="8Y_15Y"
#run_male_female
#theage="15Y_19Y"
#run_male_female

#C3
inval="C3"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
theage="1Y_19Y"
run_male_female

#C4
inval="C4"
theage="0Y_1Y"
run_male_female
theage="1Y_19Y"
run_male_female

#Haptoglobin
inval="HPT"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
theage="1Y_12Y"
run_male_female
theage="12Y_19Y"
run_male_female

#IgA
inval="IGA"
theage="0Y_1Y"
run_male_female
theage="1Y_3Y"
run_male_female
theage="3Y_6Y"
run_male_female
theage="6Y_14Y"
run_male_female
theage="14Y_19Y"
run_male_female

#IgG
inval="IGG"
theage="0D_15D"
run_male_female
theage="15D_365D"
run_male_female
theage="1Y_4Y"
run_male_female
theage="4Y_10Y"
run_male_female
theage="10Y_19Y"
run_male_female

#IgM
inval="IGM"
theage="0D_15D"
run_male_female
theage="15D_91D" #13 weeks => 91 days
run_male_female
theage="91D_365D"
run_male_female
theage="1Y_19Y"
run_male_female

#Pre-albumin
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

#Total Protein
inval="PROT"
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

#Transferrin
inval="TSF"
theage="0D_63D" #9 weeks => 63 days
run_male_female
theage="63D_365D"
run_male_female
theage="1Y_19Y"
run_male_female

#Run Direct Bilirubin
#inval="DBIL"
#theage="0D_15D"
#run_male_female
#theage="15D_365D"
#run_male_female
#theage="1Y_9Y"
#run_male_female
#theage="9Y_13Y"
#run_male_female
#theage="13Y_19Y"
#run_male_female

#Run Total Bilirubin
#inval="TBIL"
#theage="0D_15D"
#run_male_female
#theage="15D_365D"
#run_male_female
#theage="1Y_9Y"
#run_male_female
#theage="9Y_12Y"
#run_male_female
#theage="12Y_15Y"
#run_male_female
#theage="15Y_19Y"
#run_male_female


#Run CO2
#inval="CO2"
#theage="0D_15D"
#run_male_female
#theage="15D_365D"
#run_male_female
#theage="1Y_5Y"
#run_male_female
#theage="5Y_15Y"
#run_male_female
#theage="15Y_19Y"
#run_male_female

#Run Creatinine
#inval="CREAT" #Jaffe
#theage="0D_15D"
#run_male_female
#theage="15D_365D"
#run_male_female
#theage="1Y_4Y"
#run_male_female
#theage="4Y_7Y"
#run_male_female
#theage="7Y_12Y"
#run_male_female
#theage="12Y_15Y"
#run_male_female
#theage="15Y_17Y"
#run_male_female
#theage="17Y_19Y"
#run_male_female

#Magnesium
#inval="MAG"
#theage="0D_15D"
#run_male_female
#theage="15D_365D"
#run_male_female
#theage="1Y_19Y"
#run_male_female

#Urea Nitrogen
#inval="UN"
#theage="0D_15D"
#run_male_female
#theage="15D_365D"
#run_male_female
#theage="1Y_10Y"
#run_male_female
#theage="10Y_19Y"
#run_male_female

#Cholinesterase
#inval="PCHE"
#theage="0D_15D"
#run_male_female
#theage="15D_365D"
#run_male_female
#theage="1Y_17Y"
#run_male_female
#theage="17Y_19Y"

#GGP
#inval="GGTP"
#theage="0D_15D"
#run_male_female
#theage="15D_365D"
#run_male_female
#theage="1Y_11Y"
#run_male_female
#theage="11Y_19Y"

#Lipase
#inval="LIP"
#theage="0Y_19Y"
#run_male_female

#Apo A1
#inval="APOA1"
#theage="0D_15D"
#run_male_female
#theage="15D_365D"
#run_male_female
#theage="1Y_14Y"
#run_male_female
#theage="14Y_19Y"
#run_male_female

#Dirext, HDL
#inval="HDL"
#theage="0D_15D"
#run_male_female
#theage="15D_365D"
#run_male_female
#theage="1Y_4Y"
#run_male_female
#theage="4Y_13Y"
#run_male_female
#theage="13Y_19Y"
#run_male_female

#ASO
#inval="ASO,ASO O"
#theage="0D_183D" #6 months => 183 days
#run_male_female
#theage="183D_365D"
#run_male_female
#theage="1Y_6Y"
#run_male_female
#theage="6Y_19Y"
#run_male_female

#Hs-CRP
#inval="HSCRP"
#theage="0D_15D"
#run_male_female
#theage="15D_5475D" #15 years => 5475D
#run_male_female
#theage="15Y_19Y"

#Rheumatoid Factor
#inval="RF"
#theage="0D_15D"
#run_male_female
#theage="15D_6935D" #19 years => 6935 days
#run_male_female

popd
