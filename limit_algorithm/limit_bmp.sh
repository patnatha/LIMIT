source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=16/' Nate_Limit.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=16gb/' Nate_Limit.pbs

singularValue="random"
tolistpath="${preparedir}basic_metabolic_panel/outpatient_and_never_inpatient/"
run_dir_limit

