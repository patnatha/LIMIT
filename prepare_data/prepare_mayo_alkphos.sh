source ../basedir.sh

#Set the output directory
outdir="${preparedir}mayo_alk_phos/"
mkdir -p $outdir

#Set basic variables
incGrp="outpatient"
therace="all"
inval="ALK"

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs
thesex="male"
    theage="4Y_5Y"
    run_em_prepare
    theage="5Y_6Y"
    run_em_prepare
    theage="6Y_7Y"
    run_em_prepare
    theage="7Y_8Y"
    run_em_prepare
    theage="8Y_9Y"
    run_em_prepare
    theage="9Y_10Y"
    run_em_prepare
    theage="10Y_11Y"
    run_em_prepare
    theage="11Y_12Y"
    run_em_prepare
    theage="12Y_13Y"
    run_em_prepare
    theage="13Y_14Y"
    run_em_prepare
    theage="14Y_15Y"
    run_em_prepare
    theage="15Y_16Y"
    run_em_prepare
    theage="16Y_17Y"
    run_em_prepare
    theage="17Y_18Y"
    run_em_prepare
    theage="18Y_19Y"
    run_em_prepare

    sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=16gb/' prepare_data.pbs
    theage="19Y_150Y"
    run_em_prepare 
   
sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs
thesex="female"
    theage="4Y_5Y"
    run_em_prepare
    theage="5Y_6Y"
    run_em_prepare
    theage="6Y_7Y"
    run_em_prepare
    theage="7Y_8Y"
    run_em_prepare
    theage="8Y_9Y"
    run_em_prepare
    theage="9Y_10Y"
    run_em_prepare
    theage="10Y_11Y"
    run_em_prepare
    theage="11Y_12Y"
    run_em_prepare
    theage="12Y_13Y"
    run_em_prepare
    theage="13Y_14Y"
    run_em_prepare
    theage="14Y_15Y"
    run_em_prepare
    theage="15Y_16Y"
    run_em_prepare
    theage="16Y_17Y"
    run_em_prepare

    sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=16gb/' prepare_data.pbs

    theage="17Y_24Y"
    run_em_prepare

    theage="24Y_46Y"
    run_em_prepare

    theage="46Y_51Y"
    run_em_prepare

    theage="51Y_56Y"
    run_em_prepare

    theage="56Y_61Y"
    run_em_prepare

    theage="61Y_66Y"
    run_em_prepare

    theage="66Y_150Y"
    run_em_prepare


