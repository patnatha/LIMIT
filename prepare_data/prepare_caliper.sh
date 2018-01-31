source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=16gb/' prepare_data.pbs

run_male_female(){
    thesex="male"
    run_em_prepare
    thesex="female"
    run_em_prepare
}

#Set the output directory
outdir="${preparedir}caliper/"
mkdir -p $outdir

#Set basic variables
incGrp="outpatient"
therace="all"

#Run Creatinine
inval="CREAT"
theage="0D_14D"
run_male_female
theage="15D_365DY"
run_male_female
theage="1Y_4Y"
run_male_female
theage="4Y_7Y"
run_male_female
theage="7Y_12Y"
run_male_female
theage="12Y_15Y"
run_male_female
theage="15Y_17Y"
run_male_female
theage="17Y_19Y"
run_male_female

#Run Iron
inval="IRON"
theage="0Y_14Y"
run_male_female
theage="14Y_19Y"
run_male_female

#Magnesium
inval="MAG"
theage="0D_14D"
run_male_female
theage="14D_365D"
run_male_female
theage="1Y_19Y"
run_male_female

#Phosphorus
inval="PHOS"
theage="0D_14D"
run_male_female
theage="15D_365DY"
run_male_female
theage="1Y_5Y"
run_male_female
theage="5Y_13Y"
run_male_female
theage="13Y_16Y"
run_male_female
theage="16Y_19Y"
run_male_female

#Urea Nitrogen
inval="UN"
theage="0Y_14D"
run_male_female
theage="14D_365D"
run_male_female
theage="1Y_10Y"
run_male_female
theage="10Y_19Y"
run_male_female

#Uric Acid
inval="URIC"
theage="0D_14D"
run_male_female
theage="14D_365D"
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
theage="0D_14D"
run_male_female
theage="14D_91D"
run_male_female
theage="91D_365D"
run_male_female
theage="1Y_19Y"
run_male_female

#AST
inval="AST"
theage="0Y_1Y"
run_male_female
theage="1Y_13Y"
run_male_female
theage="13Y_19Y"
run_male_female



