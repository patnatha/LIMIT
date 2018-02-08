source ../basedir.sh
toswitch="ALK"
switch_input

#Set basic variables
incGrp="outpatient"
therace="all"
inval="ALK"

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' prepare_data.pbs
thesex="male"
    theage="0D_14D"
    run_em_prepare

    theage="14D_730D"
    run_em_prepare

    theage="2Y_10Y"
    run_em_prepare

    theage="10Y_13Y"
    run_em_prepare

    theage="13Y_15Y"
    run_em_prepare

    theage="15Y_17Y"
    run_em_prepare

    theage="17Y_19Y"
    run_em_prepare

    sed -i 's/ppn=[0-9]\+/ppn=12/' prepare_data.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs
    theage="19Y_150Y"
    run_em_prepare

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' prepare_data.pbs
thesex="female"
    theage="0D_14D"
    run_em_prepare

    theage="14D_730D"
    run_em_prepare

    theage="2Y_10Y"
    run_em_prepare

    theage="10Y_13Y"
    run_em_prepare

    theage="13Y_15Y"
    run_em_prepare

    theage="15Y_17Y"
    run_em_prepare

    theage="17Y_19Y"
    run_em_prepare

    sed -i 's/ppn=[0-9]\+/ppn=12/' prepare_data.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs
    theage="19Y_150Y"
    run_em_prepare


