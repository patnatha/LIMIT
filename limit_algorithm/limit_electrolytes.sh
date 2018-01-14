source ../basedir.sh

sed -i 's/ppn=[0-9]\+/ppn=16/' prepare_data.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=16gb/' prepare_data.pbs

singularValue="random"
tolistpath="${preparedir}other_electrolytes/"
run_dir_limit

