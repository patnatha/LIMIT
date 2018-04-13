pushd ../
source ../basedir.sh
toswitch="TRAIN_TEST"
switch_input

sed -i 's/ppn=[0-9]\+/ppn=4/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' prepare_data.pbs

incGrp="outpatient"
therace="all"
startDate="2013-01-01"
endDate="2018-01-01"
maxSample=10000

inval="ALT"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="ALT"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="ALB"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="ALB"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="ALK"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="ALK"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="AMY"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="AMY"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="ASO"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="ASO"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="APOA1"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="APOA1"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="APOB"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="APOB"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="AST"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="AST"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="DBIL"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="DBIL"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="TBIL"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="TBIL"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="CAL"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="CAL"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="CO2"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="CO2"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="CHOL"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="CHOL"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="VITB12"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="VITB12"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="C3"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="C3"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="C4"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="C4"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="CORT"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="CORT"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="CRP"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="CRP"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="CREAT"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="HDL"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="HDL"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="FRTN"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="FRTN"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="FOL"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="FOL"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="FT3"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="FT3"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="FT4"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="FT4"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="GGTP"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="GGTP"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="HAPT"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="HAPT"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="HCY"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="HCY"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="IGA"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="IGA"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="IGG"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="IGG"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="IGM"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="IGM"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="IPTH"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="IPTH"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="IRON"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="IRON"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="LDH"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="LDH"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="LIP"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="LIP"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="MAG"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="MAG"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="PHOS"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="PHOS"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="PAB"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="PAB"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="PRL"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="PRL"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="RF"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="RF"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="SHBG"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="SHBG"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="PROT"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="PROT"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="TSF"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="TSF"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="TRIG"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="TRIG"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="TROP"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="TROP"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="T3"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="T3"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="T4"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="T4"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="UN"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="UN"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="URIC"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="URIC"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="25HD"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="25HD"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="B2MIC"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="B2MIC"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="CERULO"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="CERULO"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="CPEP"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="CPEP"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="IGE"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="IGE"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="INS"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="INS"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="AFP"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="AFP"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="CA15-3"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="CA15-3"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="CA125"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="CEA"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="CEA"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="HE4"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="TESTB"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="TESTB"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="RETINOL"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="RETINOL"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="A TOCO"
theage="6935D_54750D"
thesex="male"
run_em_prepare

inval="A TOCO"
theage="6935D_54750D"
thesex="female"
run_em_prepare

inval="25HD"
theage="5D_15D"
thesex="male"
run_em_prepare

inval="25HD"
theage="15D_91D"
thesex="male"
run_em_prepare

inval="25HD"
theage="91D_365D"
thesex="male"
run_em_prepare

inval="25HD"
theage="365D_3285D"
thesex="male"
run_em_prepare

inval="25HD"
theage="3285D_5110D"
thesex="male"
run_em_prepare

inval="25HD"
theage="5110D_6935D"
thesex="male"
run_em_prepare

inval="25HD"
theage="5D_15D"
thesex="female"
run_em_prepare

inval="25HD"
theage="15D_91D"
thesex="female"
run_em_prepare

inval="25HD"
theage="91D_365D"
thesex="female"
run_em_prepare

inval="25HD"
theage="365D_3285D"
thesex="female"
run_em_prepare

inval="25HD"
theage="3285D_5110D"
thesex="female"
run_em_prepare

inval="25HD"
theage="5110D_6935D"
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
theage="0D_365D"
thesex="female"
run_em_prepare

inval="A TOCO"
theage="365D_6935D"
thesex="female"
run_em_prepare

inval="AFP"
theage="0D_30D"
thesex="male"
run_em_prepare

inval="AFP"
theage="30D_91D"
thesex="male"
run_em_prepare

inval="AFP"
theage="91D_183D"
thesex="male"
run_em_prepare

inval="AFP"
theage="183D_365D"
thesex="male"
run_em_prepare

inval="AFP"
theage="365D_1095D"
thesex="male"
run_em_prepare

inval="AFP"
theage="1095D_6935D"
thesex="male"
run_em_prepare

inval="AFP"
theage="0D_30D"
thesex="female"
run_em_prepare

inval="AFP"
theage="30D_91D"
thesex="female"
run_em_prepare

inval="AFP"
theage="91D_183D"
thesex="female"
run_em_prepare

inval="AFP"
theage="183D_365D"
thesex="female"
run_em_prepare

inval="AFP"
theage="365D_1095D"
thesex="female"
run_em_prepare

inval="AFP"
theage="1095D_6935D"
thesex="female"
run_em_prepare

inval="ALB"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="ALB"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="ALB"
theage="365D_2920D"
thesex="male"
run_em_prepare

inval="ALB"
theage="2920D_5475D"
thesex="male"
run_em_prepare

inval="ALB"
theage="5475D_6935D"
thesex="male"
run_em_prepare

inval="ALB"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="ALB"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="ALB"
theage="365D_2920D"
thesex="female"
run_em_prepare

inval="ALB"
theage="2920D_5475D"
thesex="female"
run_em_prepare

inval="ALB"
theage="5475D_6935D"
thesex="female"
run_em_prepare

inval="ALK"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="ALK"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="ALK"
theage="365D_3650D"
thesex="male"
run_em_prepare

inval="ALK"
theage="3650D_4745D"
thesex="male"
run_em_prepare

inval="ALK"
theage="4745D_5475D"
thesex="male"
run_em_prepare

inval="ALK"
theage="5475D_6205D"
thesex="male"
run_em_prepare

inval="ALK"
theage="6205D_6935D"
thesex="male"
run_em_prepare

inval="ALK"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="ALK"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="ALK"
theage="365D_3650D"
thesex="female"
run_em_prepare

inval="ALK"
theage="3650D_4745D"
thesex="female"
run_em_prepare

inval="ALK"
theage="4745D_5475D"
thesex="female"
run_em_prepare

inval="ALK"
theage="5475D_6205D"
thesex="female"
run_em_prepare

inval="ALK"
theage="6205D_6935D"
thesex="female"
run_em_prepare

inval="ALT"
theage="0D_365D"
thesex="male"
run_em_prepare

inval="ALT"
theage="365D_4745D"
thesex="male"
run_em_prepare

inval="ALT"
theage="4745D_6935D"
thesex="male"
run_em_prepare

inval="ALT"
theage="0D_365D"
thesex="female"
run_em_prepare

inval="ALT"
theage="365D_4745D"
thesex="female"
run_em_prepare

inval="ALT"
theage="4745D_6935D"
thesex="female"
run_em_prepare

inval="AMYL"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="AMYL"
theage="15D_91D"
thesex="male"
run_em_prepare

inval="AMYL"
theage="91D_365D"
thesex="male"
run_em_prepare

inval="AMYL"
theage="365D_6935D"
thesex="male"
run_em_prepare

inval="AMYL"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="AMYL"
theage="15D_91D"
thesex="female"
run_em_prepare

inval="AMYL"
theage="91D_365D"
thesex="female"
run_em_prepare

inval="AMYL"
theage="365D_6935D"
thesex="female"
run_em_prepare

inval="APOA1"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="APOA1"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="APOA1"
theage="365D_5110D"
thesex="male"
run_em_prepare

inval="APOA1"
theage="5110D_6935D"
thesex="male"
run_em_prepare

inval="APOA1"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="APOA1"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="APOA1"
theage="365D_5110D"
thesex="female"
run_em_prepare

inval="APOA1"
theage="5110D_6935D"
thesex="female"
run_em_prepare

inval="APOB"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="APOB"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="APOB"
theage="365D_2190D"
thesex="male"
run_em_prepare

inval="APOB"
theage="2190D_6935D"
thesex="male"
run_em_prepare

inval="APOB"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="APOB"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="APOB"
theage="365D_2190D"
thesex="female"
run_em_prepare

inval="APOB"
theage="2190D_6935D"
thesex="female"
run_em_prepare

inval="ASO"
theage="0D_183D"
thesex="male"
run_em_prepare

inval="ASO"
theage="183D_365D"
thesex="male"
run_em_prepare

inval="ASO"
theage="365D_2190D"
thesex="male"
run_em_prepare

inval="ASO"
theage="2190D_6935D"
thesex="male"
run_em_prepare

inval="ASO"
theage="0D_183D"
thesex="female"
run_em_prepare

inval="ASO"
theage="183D_365D"
thesex="female"
run_em_prepare

inval="ASO"
theage="365D_2190D"
thesex="female"
run_em_prepare

inval="ASO"
theage="2190D_6935D"
thesex="female"
run_em_prepare

inval="AST"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="AST"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="AST"
theage="365D_2555D"
thesex="male"
run_em_prepare

inval="AST"
theage="2555D_4380D"
thesex="male"
run_em_prepare

inval="AST"
theage="4380D_6935D"
thesex="male"
run_em_prepare

inval="AST"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="AST"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="AST"
theage="365D_2555D"
thesex="female"
run_em_prepare

inval="AST"
theage="2555D_4380D"
thesex="female"
run_em_prepare

inval="AST"
theage="4380D_6935D"
thesex="female"
run_em_prepare

inval="B2MIC"
theage="0D_91D"
thesex="male"
run_em_prepare

inval="B2MIC"
theage="91D_730D"
thesex="male"
run_em_prepare

inval="B2MIC"
theage="730D_6935D"
thesex="male"
run_em_prepare

inval="B2MIC"
theage="0D_91D"
thesex="female"
run_em_prepare

inval="B2MIC"
theage="91D_730D"
thesex="female"
run_em_prepare

inval="B2MIC"
theage="730D_6935D"
thesex="female"
run_em_prepare

inval="BDIL"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="BDIL"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="BDIL"
theage="365D_3285D"
thesex="male"
run_em_prepare

inval="BDIL"
theage="3285D_4745D"
thesex="male"
run_em_prepare

inval="BDIL"
theage="4745D_6935D"
thesex="male"
run_em_prepare

inval="BDIL"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="BDIL"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="BDIL"
theage="365D_3285D"
thesex="female"
run_em_prepare

inval="BDIL"
theage="3285D_4745D"
thesex="female"
run_em_prepare

inval="BDIL"
theage="4745D_6935D"
thesex="female"
run_em_prepare

inval="C3"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="C3"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="C3"
theage="365D_6935D"
thesex="male"
run_em_prepare

inval="C3"
theage="0D_365D"
thesex="male"
run_em_prepare

inval="C3"
theage="365D_6935D"
thesex="male"
run_em_prepare

inval="C3"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="C3"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="C3"
theage="365D_6935D"
thesex="female"
run_em_prepare

inval="C3"
theage="0D_365D"
thesex="female"
run_em_prepare

inval="C3"
theage="365D_6935D"
thesex="female"
run_em_prepare

inval="CA125"
theage="0D_122D"
thesex="female"
run_em_prepare

inval="CA125"
theage="122D_1825D"
thesex="female"
run_em_prepare

inval="CA125"
theage="1825D_4015D"
thesex="female"
run_em_prepare

inval="CA125"
theage="4015D_6935D"
thesex="female"
run_em_prepare

inval="CA15-3"
theage="0D_7D"
thesex="male"
run_em_prepare

inval="CA15-3"
theage="7D_365D"
thesex="male"
run_em_prepare

inval="CA15-3"
theage="365D_6935D"
thesex="male"
run_em_prepare

inval="CA15-3"
theage="0D_7D"
thesex="female"
run_em_prepare

inval="CA15-3"
theage="7D_365D"
thesex="female"
run_em_prepare

inval="CA15-3"
theage="365D_6935D"
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
theage="0D_365D"
thesex="female"
run_em_prepare

inval="CAL"
theage="365D_6935D"
thesex="female"
run_em_prepare

inval="CEA"
theage="0D_7D"
thesex="male"
run_em_prepare

inval="CEA"
theage="7D_730D"
thesex="male"
run_em_prepare

inval="CEA"
theage="730D_6935D"
thesex="male"
run_em_prepare

inval="CEA"
theage="0D_7D"
thesex="female"
run_em_prepare

inval="CEA"
theage="7D_730D"
thesex="female"
run_em_prepare

inval="CEA"
theage="730D_6935D"
thesex="female"
run_em_prepare

inval="CERULO"
theage="0D_61D"
thesex="male"
run_em_prepare

inval="CERULO"
theage="61D_183D"
thesex="male"
run_em_prepare

inval="CERULO"
theage="183D_365D"
thesex="male"
run_em_prepare

inval="CERULO"
theage="365D_2920D"
thesex="male"
run_em_prepare

inval="CERULO"
theage="2920D_5110D"
thesex="male"
run_em_prepare

inval="CERULO"
theage="5110D_6935D"
thesex="male"
run_em_prepare

inval="CERULO"
theage="0D_61D"
thesex="female"
run_em_prepare

inval="CERULO"
theage="61D_183D"
thesex="female"
run_em_prepare

inval="CERULO"
theage="183D_365D"
thesex="female"
run_em_prepare

inval="CERULO"
theage="365D_2920D"
thesex="female"
run_em_prepare

inval="CERULO"
theage="2920D_5110D"
thesex="female"
run_em_prepare

inval="CERULO"
theage="5110D_6935D"
thesex="female"
run_em_prepare

inval="CHOL"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="CHOL"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="CHOL"
theage="365D_6935D"
thesex="male"
run_em_prepare

inval="CHOL"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="CHOL"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="CHOL"
theage="365D_6935D"
thesex="female"
run_em_prepare

inval="CO2"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="CO2"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="CO2"
theage="365D_1825D"
thesex="male"
run_em_prepare

inval="CO2"
theage="1825D_5475D"
thesex="male"
run_em_prepare

inval="CO2"
theage="5475D_6935D"
thesex="male"
run_em_prepare

inval="CO2"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="CO2"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="CO2"
theage="365D_1825D"
thesex="female"
run_em_prepare

inval="CO2"
theage="1825D_5475D"
thesex="female"
run_em_prepare

inval="CO2"
theage="5475D_6935D"
thesex="female"
run_em_prepare

inval="CORT"
theage="2D_15D"
thesex="male"
run_em_prepare

inval="CORT"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="CORT"
theage="365D_3285D"
thesex="male"
run_em_prepare

inval="CORT"
theage="3285D_5110D"
thesex="male"
run_em_prepare

inval="CORT"
theage="5110D_6205D"
thesex="male"
run_em_prepare

inval="CORT"
theage="6205D_6935D"
thesex="male"
run_em_prepare

inval="CORT"
theage="2D_15D"
thesex="female"
run_em_prepare

inval="CORT"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="CORT"
theage="365D_3285D"
thesex="female"
run_em_prepare

inval="CORT"
theage="3285D_5110D"
thesex="female"
run_em_prepare

inval="CORT"
theage="5110D_6205D"
thesex="female"
run_em_prepare

inval="CORT"
theage="6205D_6935D"
thesex="female"
run_em_prepare

inval="CPEP"
theage="0D_365D"
thesex="male"
run_em_prepare

inval="CPEP"
theage="365D_2190D"
thesex="male"
run_em_prepare

inval="CPEP"
theage="2190D_6935D"
thesex="male"
run_em_prepare

inval="CPEP"
theage="0D_365D"
thesex="female"
run_em_prepare

inval="CPEP"
theage="365D_2190D"
thesex="female"
run_em_prepare

inval="CPEP"
theage="2190D_6935D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="CREAT"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="CREAT"
theage="365D_1460D"
thesex="male"
run_em_prepare

inval="CREAT"
theage="1460D_2555D"
thesex="male"
run_em_prepare

inval="CREAT"
theage="2555D_4380D"
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
theage="0D_15D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="365D_1460D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="1460D_2555D"
thesex="female"
run_em_prepare

inval="CREAT"
theage="2555D_4380D"
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

inval="CRP"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="CRP"
theage="15D_5475D"
thesex="male"
run_em_prepare

inval="CRP"
theage="5475D_6935D"
thesex="male"
run_em_prepare

inval="CRP"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="CRP"
theage="15D_5475D"
thesex="female"
run_em_prepare

inval="CRP"
theage="5475D_6935D"
thesex="female"
run_em_prepare

inval="FOL"
theage="5D_365D"
thesex="male"
run_em_prepare

inval="FOL"
theage="365D_1095D"
thesex="male"
run_em_prepare

inval="FOL"
theage="1095D_2190D"
thesex="male"
run_em_prepare

inval="FOL"
theage="2190D_2920D"
thesex="male"
run_em_prepare

inval="FOL"
theage="2920D_4380D"
thesex="male"
run_em_prepare

inval="FOL"
theage="4380D_5110D"
thesex="male"
run_em_prepare

inval="FOL"
theage="5110D_6935D"
thesex="male"
run_em_prepare

inval="FOL"
theage="5D_365D"
thesex="female"
run_em_prepare

inval="FOL"
theage="365D_1095D"
thesex="female"
run_em_prepare

inval="FOL"
theage="1095D_2190D"
thesex="female"
run_em_prepare

inval="FOL"
theage="2190D_2920D"
thesex="female"
run_em_prepare

inval="FOL"
theage="2920D_4380D"
thesex="female"
run_em_prepare

inval="FOL"
theage="4380D_5110D"
thesex="female"
run_em_prepare

inval="FOL"
theage="5110D_6935D"
thesex="female"
run_em_prepare

inval="FRTN"
theage="4D_15D"
thesex="male"
run_em_prepare

inval="FRTN"
theage="15D_183D"
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
theage="1825D_5110D"
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
theage="4D_15D"
thesex="female"
run_em_prepare

inval="FRTN"
theage="15D_183D"
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
theage="1825D_5110D"
thesex="female"
run_em_prepare

inval="FRTN"
theage="5110D_6935D"
thesex="female"
run_em_prepare

inval="FT3"
theage="4D_365D"
thesex="male"
run_em_prepare

inval="FT3"
theage="365D_4380D"
thesex="male"
run_em_prepare

inval="FT3"
theage="4380D_5475D"
thesex="male"
run_em_prepare

inval="FT3"
theage="5475D_6935D"
thesex="male"
run_em_prepare

inval="FT3"
theage="4D_365D"
thesex="female"
run_em_prepare

inval="FT3"
theage="365D_4380D"
thesex="female"
run_em_prepare

inval="FT3"
theage="4380D_5475D"
thesex="female"
run_em_prepare

inval="FT3"
theage="5475D_6935D"
thesex="female"
run_em_prepare

inval="FT4"
theage="5D_15D"
thesex="male"
run_em_prepare

inval="FT4"
theage="15D_30D"
thesex="male"
run_em_prepare

inval="FT4"
theage="30D_365D"
thesex="male"
run_em_prepare

inval="FT4"
theage="365D_6935D"
thesex="male"
run_em_prepare

inval="FT4"
theage="5D_15D"
thesex="female"
run_em_prepare

inval="FT4"
theage="15D_30D"
thesex="female"
run_em_prepare

inval="FT4"
theage="30D_365D"
thesex="female"
run_em_prepare

inval="FT4"
theage="365D_6935D"
thesex="female"
run_em_prepare

inval="GGTP"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="GGTP"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="GGTP"
theage="365D_4015D"
thesex="male"
run_em_prepare

inval="GGTP"
theage="4015D_6935D"
thesex="male"
run_em_prepare

inval="GGTP"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="GGTP"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="GGTP"
theage="365D_4015D"
thesex="female"
run_em_prepare

inval="GGTP"
theage="4015D_6935D"
thesex="female"
run_em_prepare

inval="HAPT"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="HAPT"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="HAPT"
theage="365D_4380D"
thesex="male"
run_em_prepare

inval="HAPT"
theage="4380D_6935D"
thesex="male"
run_em_prepare

inval="HAPT"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="HAPT"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="HAPT"
theage="365D_4380D"
thesex="female"
run_em_prepare

inval="HAPT"
theage="4380D_6935D"
thesex="female"
run_em_prepare

inval="HCY"
theage="5D_365D"
thesex="male"
run_em_prepare

inval="HCY"
theage="365D_2555D"
thesex="male"
run_em_prepare

inval="HCY"
theage="2555D_4380D"
thesex="male"
run_em_prepare

inval="HCY"
theage="4380D_5475D"
thesex="male"
run_em_prepare

inval="HCY"
theage="5475D_6935D"
thesex="male"
run_em_prepare

inval="HCY"
theage="5D_365D"
thesex="female"
run_em_prepare

inval="HCY"
theage="365D_2555D"
thesex="female"
run_em_prepare

inval="HCY"
theage="2555D_4380D"
thesex="female"
run_em_prepare

inval="HCY"
theage="4380D_5475D"
thesex="female"
run_em_prepare

inval="HCY"
theage="5475D_6935D"
thesex="female"
run_em_prepare

inval="HDL"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="HDL"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="HDL"
theage="365D_1460D"
thesex="male"
run_em_prepare

inval="HDL"
theage="1460D_4745D"
thesex="male"
run_em_prepare

inval="HDL"
theage="4745D_6935D"
thesex="male"
run_em_prepare

inval="HDL"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="HDL"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="HDL"
theage="365D_1460D"
thesex="female"
run_em_prepare

inval="HDL"
theage="1460D_4745D"
thesex="female"
run_em_prepare

inval="HDL"
theage="4745D_6935D"
thesex="female"
run_em_prepare

inval="IGA"
theage="0D_365D"
thesex="male"
run_em_prepare

inval="IGA"
theage="365D_1095D"
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
theage="5110D_6935D"
thesex="male"
run_em_prepare

inval="IGA"
theage="0D_365D"
thesex="female"
run_em_prepare

inval="IGA"
theage="365D_1095D"
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
theage="5110D_6935D"
thesex="female"
run_em_prepare

inval="IGE"
theage="0D_2555D"
thesex="male"
run_em_prepare

inval="IGE"
theage="2555D_6935D"
thesex="male"
run_em_prepare

inval="IGE"
theage="0D_2555D"
thesex="female"
run_em_prepare

inval="IGE"
theage="2555D_6935D"
thesex="female"
run_em_prepare

inval="IGG"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="IGG"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="IGG"
theage="365D_1460D"
thesex="male"
run_em_prepare

inval="IGG"
theage="1460D_3650D"
thesex="male"
run_em_prepare

inval="IGG"
theage="3650D_6935D"
thesex="male"
run_em_prepare

inval="IGG"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="IGG"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="IGG"
theage="365D_1460D"
thesex="female"
run_em_prepare

inval="IGG"
theage="1460D_3650D"
thesex="female"
run_em_prepare

inval="IGG"
theage="3650D_6935D"
thesex="female"
run_em_prepare

inval="IGM"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="IGM"
theage="15D_91D"
thesex="male"
run_em_prepare

inval="IGM"
theage="91D_365D"
thesex="male"
run_em_prepare

inval="IGM"
theage="365D_6935D"
thesex="male"
run_em_prepare

inval="IGM"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="IGM"
theage="15D_91D"
thesex="female"
run_em_prepare

inval="IGM"
theage="91D_365D"
thesex="female"
run_em_prepare

inval="IGM"
theage="365D_6935D"
thesex="female"
run_em_prepare

inval="INS"
theage="0D_365D"
thesex="male"
run_em_prepare

inval="INS"
theage="365D_2190D"
thesex="male"
run_em_prepare

inval="INS"
theage="2190D_6935D"
thesex="male"
run_em_prepare

inval="INS"
theage="0D_365D"
thesex="female"
run_em_prepare

inval="INS"
theage="365D_2190D"
thesex="female"
run_em_prepare

inval="INS"
theage="2190D_6935D"
thesex="female"
run_em_prepare

inval="IPTH"
theage="6D_365D"
thesex="male"
run_em_prepare

inval="IPTH"
theage="365D_3285D"
thesex="male"
run_em_prepare

inval="IPTH"
theage="3285D_6205D"
thesex="male"
run_em_prepare

inval="IPTH"
theage="6205D_6935D"
thesex="male"
run_em_prepare

inval="IPTH"
theage="6D_365D"
thesex="female"
run_em_prepare

inval="IPTH"
theage="365D_3285D"
thesex="female"
run_em_prepare

inval="IPTH"
theage="3285D_6205D"
thesex="female"
run_em_prepare

inval="IPTH"
theage="6205D_6935D"
thesex="female"
run_em_prepare

inval="IRON"
theage="0D_5110D"
thesex="male"
run_em_prepare

inval="IRON"
theage="5110D_6935D"
thesex="male"
run_em_prepare

inval="IRON"
theage="0D_5110D"
thesex="female"
run_em_prepare

inval="IRON"
theage="5110D_6935D"
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
theage="365D_3650D"
thesex="male"
run_em_prepare

inval="LDH"
theage="3650D_5475D"
thesex="male"
run_em_prepare

inval="LDH"
theage="5475D_6935D"
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
theage="365D_3650D"
thesex="female"
run_em_prepare

inval="LDH"
theage="3650D_5475D"
thesex="female"
run_em_prepare

inval="LDH"
theage="5475D_6935D"
thesex="female"
run_em_prepare

inval="LIP"
theage="0D_6935D"
thesex="male"
run_em_prepare

inval="LIP"
theage="0D_6935D"
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

inval="PAB"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="PAB"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="PAB"
theage="365D_1825D"
thesex="male"
run_em_prepare

inval="PAB"
theage="1825D_4745D"
thesex="male"
run_em_prepare

inval="PAB"
theage="4745D_5840D"
thesex="male"
run_em_prepare

inval="PAB"
theage="5840D_6935D"
thesex="male"
run_em_prepare

inval="PAB"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="PAB"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="PAB"
theage="365D_1825D"
thesex="female"
run_em_prepare

inval="PAB"
theage="1825D_4745D"
thesex="female"
run_em_prepare

inval="PAB"
theage="4745D_5840D"
thesex="female"
run_em_prepare

inval="PAB"
theage="5840D_6935D"
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
theage="365D_1825D"
thesex="male"
run_em_prepare

inval="PHOS"
theage="1825D_4745D"
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
theage="0D_15D"
thesex="female"
run_em_prepare

inval="PHOS"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="PHOS"
theage="365D_1825D"
thesex="female"
run_em_prepare

inval="PHOS"
theage="1825D_4745D"
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

inval="PRL"
theage="4D_30D"
thesex="male"
run_em_prepare

inval="PRL"
theage="30D_365D"
thesex="male"
run_em_prepare

inval="PRL"
theage="365D_6935D"
thesex="male"
run_em_prepare

inval="PRL"
theage="4D_30D"
thesex="female"
run_em_prepare

inval="PRL"
theage="30D_365D"
thesex="female"
run_em_prepare

inval="PRL"
theage="365D_6935D"
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
theage="365D_2190D"
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
theage="0D_15D"
thesex="female"
run_em_prepare

inval="PROT"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="PROT"
theage="365D_2190D"
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

inval="RETINOL"
theage="0D_365D"
thesex="male"
run_em_prepare

inval="RETINOL"
theage="365D_4015D"
thesex="male"
run_em_prepare

inval="RETINOL"
theage="4015D_5840D"
thesex="male"
run_em_prepare

inval="RETINOL"
theage="5840D_6935D"
thesex="male"
run_em_prepare

inval="RETINOL"
theage="0D_365D"
thesex="female"
run_em_prepare

inval="RETINOL"
theage="365D_4015D"
thesex="female"
run_em_prepare

inval="RETINOL"
theage="4015D_5840D"
thesex="female"
run_em_prepare

inval="RETINOL"
theage="5840D_6935D"
thesex="female"
run_em_prepare

inval="RF"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="RF"
theage="15D_6935D"
thesex="male"
run_em_prepare

inval="RF"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="RF"
theage="15D_6935D"
thesex="female"
run_em_prepare

inval="T3"
theage="4D_365D"
thesex="male"
run_em_prepare

inval="T3"
theage="365D_4380D"
thesex="male"
run_em_prepare

inval="T3"
theage="4380D_5475D"
thesex="male"
run_em_prepare

inval="T3"
theage="5475D_6205D"
thesex="male"
run_em_prepare

inval="T3"
theage="6205D_6935D"
thesex="male"
run_em_prepare

inval="T3"
theage="4D_365D"
thesex="female"
run_em_prepare

inval="T3"
theage="365D_4380D"
thesex="female"
run_em_prepare

inval="T3"
theage="4380D_5475D"
thesex="female"
run_em_prepare

inval="T3"
theage="5475D_6205D"
thesex="female"
run_em_prepare

inval="T3"
theage="6205D_6935D"
thesex="female"
run_em_prepare

inval="T4"
theage="7D_365D"
thesex="male"
run_em_prepare

inval="T4"
theage="365D_3285D"
thesex="male"
run_em_prepare

inval="T4"
theage="3285D_4380D"
thesex="male"
run_em_prepare

inval="T4"
theage="4380D_5110D"
thesex="male"
run_em_prepare

inval="T4"
theage="5110D_6935D"
thesex="male"
run_em_prepare

inval="T4"
theage="7D_365D"
thesex="female"
run_em_prepare

inval="T4"
theage="365D_3285D"
thesex="female"
run_em_prepare

inval="T4"
theage="3285D_4380D"
thesex="female"
run_em_prepare

inval="T4"
theage="4380D_5110D"
thesex="female"
run_em_prepare

inval="T4"
theage="5110D_6935D"
thesex="female"
run_em_prepare

inval="TBIL"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="TBIL"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="TBIL"
theage="365D_3285D"
thesex="male"
run_em_prepare

inval="TBIL"
theage="3285D_4380D"
thesex="male"
run_em_prepare

inval="TBIL"
theage="4380D_5475D"
thesex="male"
run_em_prepare

inval="TBIL"
theage="5475D_6935D"
thesex="male"
run_em_prepare

inval="TBIL"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="TBIL"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="TBIL"
theage="365D_3285D"
thesex="female"
run_em_prepare

inval="TBIL"
theage="3285D_4380D"
thesex="female"
run_em_prepare

inval="TBIL"
theage="4380D_5475D"
thesex="female"
run_em_prepare

inval="TBIL"
theage="5475D_6935D"
thesex="female"
run_em_prepare

inval="THYRGLB AB"
theage="0D_6935D"
thesex="male"
run_em_prepare

inval="THYRGLB AB"
theage="0D_6935D"
thesex="female"
run_em_prepare

inval="TRIG"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="TRIG"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="TRIG"
theage="365D_6935D"
thesex="male"
run_em_prepare

inval="TRIG"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="TRIG"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="TRIG"
theage="365D_6935D"
thesex="female"
run_em_prepare

inval="TROP"
theage="5D_15D"
thesex="male"
run_em_prepare

inval="TROP"
theage="15D_91D"
thesex="male"
run_em_prepare

inval="TROP"
theage="91D_6935D"
thesex="male"
run_em_prepare

inval="TROP"
theage="5D_15D"
thesex="female"
run_em_prepare

inval="TROP"
theage="15D_91D"
thesex="female"
run_em_prepare

inval="TROP"
theage="91D_6935D"
thesex="female"
run_em_prepare

inval="TSF"
theage="0D_63D"
thesex="male"
run_em_prepare

inval="TSF"
theage="63D_365D"
thesex="male"
run_em_prepare

inval="TSF"
theage="365D_6935D"
thesex="male"
run_em_prepare

inval="TSF"
theage="0D_63D"
thesex="female"
run_em_prepare

inval="TSF"
theage="63D_365D"
thesex="female"
run_em_prepare

inval="TSF"
theage="365D_6935D"
thesex="female"
run_em_prepare

inval="TSH"
theage="4D_183D"
thesex="male"
run_em_prepare

inval="TSH"
theage="183D_5110D"
thesex="male"
run_em_prepare

inval="TSH"
theage="5110D_6935D"
thesex="male"
run_em_prepare

inval="TSH"
theage="4D_183D"
thesex="female"
run_em_prepare

inval="TSH"
theage="183D_5110D"
thesex="female"
run_em_prepare

inval="TSH"
theage="5110D_6935D"
thesex="female"
run_em_prepare

inval="UN"
theage="0D_14D"
thesex="male"
run_em_prepare

inval="UN"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="UN"
theage="365D_3650D"
thesex="male"
run_em_prepare

inval="UN"
theage="3650D_6935D"
thesex="male"
run_em_prepare

inval="UN"
theage="0D_14D"
thesex="female"
run_em_prepare

inval="UN"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="UN"
theage="365D_3650D"
thesex="female"
run_em_prepare

inval="UN"
theage="3650D_6935D"
thesex="female"
run_em_prepare

inval="URIC"
theage="0D_15D"
thesex="male"
run_em_prepare

inval="URIC"
theage="15D_365D"
thesex="male"
run_em_prepare

inval="URIC"
theage="365D_4380D"
thesex="male"
run_em_prepare

inval="URIC"
theage="4380D_6935D"
thesex="male"
run_em_prepare

inval="URIC"
theage="0D_15D"
thesex="female"
run_em_prepare

inval="URIC"
theage="15D_365D"
thesex="female"
run_em_prepare

inval="URIC"
theage="365D_4380D"
thesex="female"
run_em_prepare

inval="URIC"
theage="4380D_6935D"
thesex="female"
run_em_prepare

inval="VITB12"
theage="5D_365D"
thesex="male"
run_em_prepare

inval="VITB12"
theage="365D_3285D"
thesex="male"
run_em_prepare

inval="VITB12"
theage="3285D_5110D"
thesex="male"
run_em_prepare

inval="VITB12"
theage="5110D_6205D"
thesex="male"
run_em_prepare

inval="VITB12"
theage="6205D_6935D"
thesex="male"
run_em_prepare

inval="VITB12"
theage="5D_365D"
thesex="female"
run_em_prepare

inval="VITB12"
theage="365D_3285D"
thesex="female"
run_em_prepare

inval="VITB12"
theage="3285D_5110D"
thesex="female"
run_em_prepare

inval="VITB12"
theage="5110D_6205D"
thesex="female"
run_em_prepare

inval="VITB12"
theage="6205D_6935D"
thesex="female"
run_em_prepare

