source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=4/' Nate_LIMIT.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=16gb/' Nate_LIMIT.pbs

singularValue="random"

tolistpath="${preparedir}HGB_HGBN/HGB_HGBN_2_groups/outpatient_and_never_inpatient/"
run_dir_limit

tolistpath="${preparedir}HGB_HGBN/HGB_HGBN_10_y_range/outpatient_and_never_inpatient/"
run_dir_limit

