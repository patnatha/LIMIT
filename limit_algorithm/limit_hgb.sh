source ../basedir.sh

singularValue="random"

sed -i 's/ppn=[0-9]\+/ppn=8/' Nate_LIMIT.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' Nate_LIMIT.pbs
tolistpath="${preparedir}HGB_HGBN/HGB_HGBN_2_groups/outpatient_and_never_inpatient/"
run_dir_limit

sed -i 's/ppn=[0-9]\+/ppn=4/' Nate_LIMIT.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=8gb/' Nate_LIMIT.pbs
tolistpath="${preparedir}HGB_HGBN/HGB_HGBN_10_y_range/outpatient_and_never_inpatient/"
run_dir_limit

