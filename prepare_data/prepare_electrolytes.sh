source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=32gb/' prepare_data.pbs

#Set the output directory
outdir="${preparedir}other_electrolytes/"
mkdir -p $outdir

#Set the include grp
incGrp="outpatient_and_never_inpatient"

#Set the bmp for all adults
thesex="both"
therace="all"
theage="adult"

inval="CAL"
run_em_prepare

inval="MAG"
run_em_prepare

inval="PHOS"
run_em_prepare

