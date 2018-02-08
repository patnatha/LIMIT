source ../basedir.sh
toswitch="ROC"
switch_input

sed -i 's/ppn=[0-9]\+/ppn=8/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

#Set the output directory
outdir="${preparedir}basic_metabolic_panel/"
mkdir -p $outdir

#Set the include grp
incGrp="outpatient_and_never_inpatient"

inval="HGB,HGBN"
thesex="male"
run_em_prepare
thesex="female"
run_em_prepare
#UMICH=male 13.5 - 17.0 (16-150), female 12.0 - 16.0 (1-150)
#Demographic  Age     Scripps NHANES
#White Male   20-59   13.4    13.4
#White Male   60+     12.8    13.2
#White Female 20-49   11.9    12
#White Female 50+     11.9    11.5
#Black Male   20-59   12.6    12.3
#Black Male   60+     N/A     11.4
#Black Female 20-49   11.2    10.9
#Black Female 50+     11.2    11

inval="WBC"
thesex="both"
therace="all"
theage="adult"
run_em_prepare
#UMICH=4.0-10.0 (16-150)
#Germany 2015: male: 3.3871-9.3694, female: 3.6340-8.8725 

inval="PLT"
thesex="both"
therace="all"
theage="adult"
run_em_prepare
#UMICH=150-400(16-150)
#Giles-1981: 150-400 (18-150)
#Italy 2013: male 120–369, female 136–436 (15 and 64 years); male 112–361, female 119–396 (64-150)

inval="SOD"
thesex="both"
therace="all"
theage="adult"
run_em_prepare
#UMICH=136-146 (12-150)
#SPIA=135-145 (18-150)
#PathHarmony=133-146 (18-150)
#NORIP=137-145 (18-150)
#SIQAG=135-145 (18-150)

inval="POT,POTPL"
thesex="both"
therace="all"
theage="adult"
run_em_prepare
#UMICH=3.5-5.0 (12-150)
#SPIA=3.5-5.2 (18-150)
#PathHarmony=3.5-5.3 (18-150)
#NORIP=3.5-4.4 (18-150)
#SIQAG=3.5-5.2 (18-150)

inval="CHLOR"
thesex="both"
therace="all"
theage="adult"
run_em_prepare
#UMICH=98-108 (1-127)
#SPIA=95-110 (18-150)
#PathHarmony=95-108 (18-150)
#NORIP=
#SIQAG=95-110 (18-150)

inval="C02"
thesex="both"
therace="all"
theage="adult"
run_em_prepare
#UMICH=22-34 (12-150)
#SPIA=22-32 (18-150)
#PathHarmony=22-29 (18-150)
#NORIP=
#SIQAG=

inval="UN"
thesex="both"
therace="all"
theage="adult"
run_em_prepare
#UMICH=1.3-3.3 (12-150)
#SPIA=
#PathHarmony=2.5-7.8 (18-150)
#NORIP=male, 3.2-8.1 (18-50), female: 2.6-6.4 (18-50), 3.1-7.9 (50 - 150)
#SIQAG=3.2-7.7 (14-150)

inval="CREAT"
thesex="both"
therace="all"
theage="adult"
thesex="male"
run_em_prepare
thesex="female"
run_em_prepare
#UMICH=male: 0.7 - 1.3 (12-150), female: 0.5 - 1.0 (12-150)
#SPIA=
#PathHarmony=
#NORIP=male: 0.724-1.11 (18-150), female: 0.588-0.95 (18-150)
#SIQAG=male: 0.566-1.244 (16-150), female: 0.51-1.018 (16-150)

