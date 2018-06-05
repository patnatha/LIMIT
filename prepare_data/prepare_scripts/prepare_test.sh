pushd ../
source ../basedir.sh
toswitch="TEST"
switch_input

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' prepare_data.pbs

incGrp="outpatient"
therace="all"
startDate="2013-01-01"
endDate="2018-01-01"

inval="A TOCO"
theage="0D_365D"
thesex="female"
run_em_prepare

inval="A TOCO"
theage="365D_6935D"
thesex="female"
run_em_prepare

inval="A TOCO"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="A TOCO"
theage="0D_365D"
thesex="male"
run_em_prepare

inval="A TOCO"
theage="365D_6935D"
thesex="male"
run_em_prepare

inval="A TOCO"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="CAL"
theage="0D_365D"
thesex="female"
run_em_prepare

inval="CAL"
theage="365D_6935D"
thesex="female"
run_em_prepare

inval="CAL"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="CAL"
theage="0D_365D"
thesex="male"
run_em_prepare

inval="CAL"
theage="365D_6935D"
thesex="male"
run_em_prepare

inval="CAL"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="CPEP"
theage="0D_365D"
thesex="female"
run_em_prepare

inval="CPEP"
theage="2190D_6935D"
thesex="female"
run_em_prepare

inval="CPEP"
theage="365D_2190D"
thesex="female"
run_em_prepare

inval="CPEP"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="CPEP"
theage="0D_365D"
thesex="male"
run_em_prepare

inval="CPEP"
theage="2190D_6935D"
thesex="male"
run_em_prepare

inval="CPEP"
theage="365D_2190D"
thesex="male"
run_em_prepare

inval="CPEP"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="CREAT"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="1460D_2555D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="2555D_4380D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="365D_1460D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="4380D_5475D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="5475D_6205D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="6205D_6935D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="CREAT"
theage="1460D_2555D"
thesex="male"
run_em_prepare

inval="CREAT"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="CREAT"
theage="2555D_4380D"
thesex="male"
run_em_prepare

inval="CREAT"
theage="365D_1460D"
thesex="male"
run_em_prepare

inval="CREAT"
theage="4380D_5475D"
thesex="male"
run_em_prepare

inval="CREAT"
theage="5475D_6205D"
thesex="male"
run_em_prepare

inval="CREAT"
theage="6205D_6935D"
thesex="male"
run_em_prepare

inval="CREAT"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="FRTN"
theage="15D_183D"
thesex="female"
run_em_prepare

inval="FRTN"
theage="1825D_5110D"
thesex="female"
run_em_prepare

inval="FRTN"
theage="183D_365D"
thesex="female"
run_em_prepare

inval="FRTN"
theage="365D_1825D"
thesex="female"
run_em_prepare

inval="FRTN"
theage="4D_15D"
thesex="female"
run_em_prepare

inval="FRTN"
theage="5110D_6935D"
thesex="female"
run_em_prepare

inval="FRTN"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="FRTN"
theage="15D_183D"
thesex="male"
run_em_prepare

inval="FRTN"
theage="1825D_5110D"
thesex="male"
run_em_prepare

inval="FRTN"
theage="183D_365D"
thesex="male"
run_em_prepare

inval="FRTN"
theage="365D_1825D"
thesex="male"
run_em_prepare

inval="FRTN"
theage="4D_15D"
thesex="male"
run_em_prepare

inval="FRTN"
theage="5110D_5840D"
thesex="male"
run_em_prepare

inval="FRTN"
theage="5840D_6935D"
thesex="male"
run_em_prepare

inval="FRTN"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="IGA"
theage="0D_365D"
thesex="female"
run_em_prepare

inval="IGA"
theage="1095D_2190D"
thesex="female"
run_em_prepare

inval="IGA"
theage="2190D_5110D"
thesex="female"
run_em_prepare

inval="IGA"
theage="365D_1095D"
thesex="female"
run_em_prepare

inval="IGA"
theage="5110D_6935D"
thesex="female"
run_em_prepare

inval="IGA"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="IGA"
theage="0D_365D"
thesex="male"
run_em_prepare

inval="IGA"
theage="1095D_2190D"
thesex="male"
run_em_prepare

inval="IGA"
theage="2190D_5110D"
thesex="male"
run_em_prepare

inval="IGA"
theage="365D_1095D"
thesex="male"
run_em_prepare

inval="IGA"
theage="5110D_6935D"
thesex="male"
run_em_prepare

inval="IGA"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="LDH"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="LDH"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="LDH"
theage="3650D_5475D"
thesex="female"
run_em_prepare

inval="LDH"
theage="365D_3650D"
thesex="female"
run_em_prepare

inval="LDH"
theage="5475D_6935D"
thesex="female"
run_em_prepare

inval="LDH"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="LDH"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="LDH"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="LDH"
theage="3650D_5475D"
thesex="male"
run_em_prepare

inval="LDH"
theage="365D_3650D"
thesex="male"
run_em_prepare

inval="LDH"
theage="5475D_6935D"
thesex="male"
run_em_prepare

inval="LDH"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="MAG"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="MAG"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="MAG"
theage="365D_6935D"
thesex="female"
run_em_prepare

inval="MAG"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="MAG"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="MAG"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="MAG"
theage="365D_6935D"
thesex="male"
run_em_prepare

inval="MAG"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="PHOS"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="PHOS"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="PHOS"
theage="1825D_4745D"
thesex="female"
run_em_prepare

inval="PHOS"
theage="365D_1825D"
thesex="female"
run_em_prepare

inval="PHOS"
theage="4745D_5840D"
thesex="female"
run_em_prepare

inval="PHOS"
theage="5840D_6935D"
thesex="female"
run_em_prepare

inval="PHOS"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="PHOS"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="PHOS"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="PHOS"
theage="1825D_4745D"
thesex="male"
run_em_prepare

inval="PHOS"
theage="365D_1825D"
thesex="male"
run_em_prepare

inval="PHOS"
theage="4745D_5840D"
thesex="male"
run_em_prepare

inval="PHOS"
theage="5840D_6935D"
thesex="male"
run_em_prepare

inval="PHOS"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="PROT"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="PROT"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="PROT"
theage="2190D_3285D"
thesex="female"
run_em_prepare

inval="PROT"
theage="3285D_6935D"
thesex="female"
run_em_prepare

inval="PROT"
theage="365D_2190D"
thesex="female"
run_em_prepare

inval="PROT"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="PROT"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="PROT"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="PROT"
theage="2190D_3285D"
thesex="male"
run_em_prepare

inval="PROT"
theage="3285D_6935D"
thesex="male"
run_em_prepare

inval="PROT"
theage="365D_2190D"
thesex="male"
run_em_prepare

inval="PROT"
theage="6935D_54750D"
thesex="male"
run_em_prepare

