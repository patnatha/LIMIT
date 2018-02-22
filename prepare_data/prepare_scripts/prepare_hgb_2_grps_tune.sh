pushd ../
source ../basedir.sh
toswitch="TUNE_HGB2"
switch_input

sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

#Set the input directory
inval="HGB"

#Set the include grp
incGrp="outpatient_and_never_inpatient"

runEm(){
    #White Male
    thesex="male"
    therace="white"
        theage="20Y_60Y"
        run_em_prepare
        theage="60Y_120Y"
        run_em_prepare

    #White Female
    thesex="female"
    therace="white"
        theage="20Y_50Y"
        run_em_prepare
        theage="50Y_120Y"
        run_em_prepare

    #Black Male
    thesex="male"
    therace="black"
        theage="20Y_60Y"
        run_em_prepare
        theage="60Y_120Y"
        run_em_prepare

    #Black Female
    thesex="female"
    therace="black"
        theage="20Y_50Y"
        run_em_prepare
        theage="50Y_120Y"
        run_em_prepare
}

#Run three different rune groups
incGrp="outpatient_and_never_inpatient"
runEm
incGrp="outpatient"
runEm
incGrp="inpatient"
runEm

popd
