source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=8/' Nate_LIMIT.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=16gb/' Nate_LIMIT.pbs

singularValue="random"
tolistpath="${preparedir}bilirubin/outpatient/"
run_dir_limit

