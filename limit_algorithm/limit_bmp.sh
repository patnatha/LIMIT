source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=12/' Nate_LIMIT.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' Nate_LIMIT.pbs

tolistpath="${preparedir}basic_metabolic_panel/outpatient_and_never_inpatient/"
run_dir_limit

