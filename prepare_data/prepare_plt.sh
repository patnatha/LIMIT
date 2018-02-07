source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

#Set the output directory
outdir="${preparedir}platelet/"
mkdir -p $outdir

#Set the include grp
incGrp="outpatient_and_never_inpatient"

inval="PLT"
thesex="both"
therace="all"
theage="adult"
run_em_prepare
#UMICH=150-400(16-150)
#Giles-1981: 150-400 (18-150)

#Run the italian parameters
thesex="male"
theage="15Y_64Y"
run_em_prepare
theage="64Y_150Y"
run_em_prepare

thesex="female"
theage="15Y_64Y"
run_em_prepare
theage="64Y_150Y"
run_em_prepare
#Italy 2013: male 120–369, female 136–436 (15 and 64 years); male 112–361, female 119–396 (64-150)

