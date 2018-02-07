source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

#Set the output directory
outdir="${preparedir}white_blood_cell/"
mkdir -p $outdir

#Set the include grp
incGrp="outpatient_and_never_inpatient"

inval="WBC"
thesex="both"
therace="all"
theage="adult"
run_em_prepare
#UMICH=4.0-10.0 (16-150)

thesex="male"
run_em_prepare
thesex="female"
run_em_prepare
#Germany 2015: male: 3.3871-9.3694, female: 3.6340-8.8725 

