source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs 
sed -i 's/pmem=[0-9]\+gb/pmem=16gb/' prepare_data.pbs

#Set the input directory
inval="HGB,HGBN"

#Set the output directories
indir=`echo $inval | sed -e 's/,/_/g'`
toutdir="${preparedir}${inval}/"
mkdir -p $toutdir
toutdirtwogrps="${toutdir}${inval}_2_groups/"
mkdir -p $toutdirtwogrps
toutdirtengrps="${toutdir}${inval}_10_y_range/"
mkdir -p $toutdirtengrps

#Set the include grp
incGrp="outpatient_and_never_inpatient"

#White Male
thesex="male"
therace="white"
    #2 Grps
    outdir=$toutdirtwogrps
    theage="20Y_60Y"
    run_em_prepare
    theage="60Y_120Y"
    run_em_prepare

    #Decade Range
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
    outdir=$toutdirtwogrps
    theage="20Y_50Y"
    run_em_prepare
    theage="50Y_120Y"
    run_em_prepare

    #Decade Range
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
    outdir=$toutdirtwogrps
    theage="20Y_60Y"
    run_em_prepare
    theage="60Y_120Y"
    run_em_prepare

    #Decade Range
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
    outdir=$toutdirtwogrps
    theage="20Y_50Y"
    run_em_prepare
    theage="50Y_120Y"
    run_em_prepare

    #Decade Range
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

