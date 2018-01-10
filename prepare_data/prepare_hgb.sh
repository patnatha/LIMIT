source ../basedir.sh

#Set the input directory
indir="hgb_5_years"

#Set the output directories
toutdir="${preparedir}hgb_5_years/"
mkdir -p $toutdir
toutdirtwogrps="${toutdir}hgb_5_years_2_groups"
mkdir -p $toutdirtwogrps
toutdirtengrps="${toutdir}hgb_5_years_10_y_range"
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

