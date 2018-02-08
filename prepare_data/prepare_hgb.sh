source ../basedir.sh
toswitch="HGB"
switch_input

#Set the input directory
inval="HGB,HGBN"

#Set the output directories
toutdirtwogrps="${preparedir}two_groups/"
mkdir -p $toutdirtwogrps
toutdirtengrps="${preparedir}decade_ranges/"
mkdir -p $toutdirtengrps

#Set the include grp
incGrp="outpatient_and_never_inpatient"

#White Male
thesex="male"
therace="white"
    #2 Grps
    sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

    outdir=$toutdirtwogrps
    theage="20Y_60Y"
    run_em_prepare
    theage="60Y_120Y"
    run_em_prepare

    #Decade Range
    sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

    outdir=$toutdirtengrps
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
    #2 Grps
    sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

    outdir=$toutdirtwogrps
    theage="20Y_50Y"
    run_em_prepare
    theage="50Y_120Y"
    run_em_prepare

    #Decade Range
    sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

    outdir=$toutdirtengrps
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
    #2 Grps
    sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

    outdir=$toutdirtwogrps
    theage="20Y_60Y"
    run_em_prepare
    theage="60Y_120Y"
    run_em_prepare

    #Decade Range
    sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

    outdir=$toutdirtengrps
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
    #2 Grps
    sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

    outdir=$toutdirtwogrps
    theage="20Y_50Y"
    run_em_prepare
    theage="50Y_120Y"
    run_em_prepare

    #Decade Range
    sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

    outdir=$toutdirtengrps
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

