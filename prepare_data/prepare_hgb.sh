#Set the input data
basedir="/scratch/leeschro_armis/patnatha/hgb_5_years"
rawfile=`basename ${basedir}`

#Set the output directory
outdir="/scratch/leeschro_armis/patnatha/prepared_data/hgb_5_years/"
mkdir -p $outdir
eval "rm -rf $outdir/*"

#Set the function
run_grp(){
    tempdir=$outdir$finoutdir
    mkdir -p $tempdir
    eval "rm -rf $tempdir/*"
    eval "qsub prepare_data.pbs -F \"--input $basedir --sex $thesex --race $therace --include $incGrp --age $theage --output ${tempdir}\""
}

#Set the include grp
incGrp="outpatient_and_never_inpatient"

#White Male
thesex="male"
therace="white"

#2 Grps
finoutdir="${rawfile}_2_groups"
theage="20Y_60Y"
run_grp
theage="60Y_120Y"
run_grp

#Decade Range
finoutdir="${rawfile}_10_y_range"
theage="20Y_30Y"
run_grp
theage="30Y_40Y"
run_grp
theage="40Y_50Y"
run_grp
theage="50Y_60Y"
run_grp
theage="60Y_70Y"
run_grp
theage="70Y_80Y"
run_grp
theage="80Y_120Y"
run_grp

#White Female
thesex="female"
therace="white"

#2 Grps
finoutdir="${rawfile}_2_groups"
theage="20Y_50Y"
run_grp
theage="50Y_120Y"
run_grp

#Decade Range
finoutdir="${rawfile}_10_y_range"
theage="20Y_30Y"
run_grp
theage="30Y_40Y"
run_grp
theage="40Y_50Y"
run_grp
theage="50Y_60Y"
run_grp
theage="60Y_70Y"
run_grp
theage="70Y_80Y"
run_grp
theage="80Y_120Y"
run_grp

#Black Male
thesex="male"
therace="black"

#2 Grps
finoutdir="${rawfile}_2_groups"
theage="20Y_60Y"
run_grp
theage="60Y_120Y"
run_grp

#Decade Range
finoutdir="${rawfile}_10_y_range"
theage="20Y_30Y"
run_grp
theage="30Y_40Y"
run_grp
theage="40Y_50Y"
run_grp
theage="50Y_60Y"
run_grp
theage="60Y_70Y"
run_grp
theage="70Y_120Y"
run_grp

#Black Female
thesex="female"
therace="black"

#2 Grps
finoutdir="${rawfile}_2_groups"
theage="20Y_50Y"
run_grp
theage="50Y_120Y"
run_grp

#Decade Range
finoutdir="${rawfile}_10_y_range"
theage="20Y_30Y"
run_grp
theage="30Y_40Y"
run_grp
theage="40Y_50Y"
run_grp
theage="50Y_60Y"
run_grp
theage="60Y_70Y"
run_grp
theage="70Y_120Y"
run_grp

