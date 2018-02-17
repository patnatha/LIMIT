source ../basedir.sh
toswitch="HGB"
switch_input

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' prepare_data.pbs

#Set the input directory
inval="HGB,HGBN"

#Set the output directories
preparedir="${preparedir::-1}_decade_ranges/"

#Set the include grp
incGrp="outpatient_and_never_inpatient"

#White Male
thesex="male"
therace="white"
    theage="20Y_30Y"
    run_em_prepare
    theage="30Y_40Y"
    run_em_prepare
    theage="40Y_50Y"
    run_em_prepare
    theage="50Y_60Y"
    run_em_prepare
    theage="60Y_70Y"
    run_em_prepare
    theage="70Y_80Y"
    run_em_prepare
    theage="80Y_120Y"
    run_em_prepare

#White Female
thesex="female"
therace="white"
    theage="20Y_30Y"
    run_em_prepare
    theage="30Y_40Y"
    run_em_prepare
    theage="40Y_50Y"
    run_em_prepare
    theage="50Y_60Y"
    run_em_prepare
    theage="60Y_70Y"
    run_em_prepare
    theage="70Y_80Y"
    run_em_prepare
    theage="80Y_120Y"
    run_em_prepare

#Black Male
thesex="male"
therace="black"
    theage="20Y_30Y"
    run_em_prepare
    theage="30Y_40Y"
    run_em_prepare
    theage="40Y_50Y"
    run_em_prepare
    theage="50Y_60Y"
    run_em_prepare
    theage="60Y_70Y"
    run_em_prepare
    theage="70Y_120Y"
    run_em_prepare

#Black Female
thesex="female"
therace="black"
    theage="20Y_30Y"
    run_em_prepare
    theage="30Y_40Y"
    run_em_prepare
    theage="40Y_50Y"
    run_em_prepare
    theage="50Y_60Y"
    run_em_prepare
    theage="60Y_70Y"
    run_em_prepare
    theage="70Y_120Y"
    run_em_prepare

