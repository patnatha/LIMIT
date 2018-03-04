source ../basedir.sh
toswitch=$1
switch_input
tolistpath=${limitdir}
post_process_dir

for tdir in $prepdirs
do
    echo $tdir
    eval "mkdir -p ${tdir}/joined"
    thecmd="Rscript exclude_combined.R --input $tdir/"
    eval $thecmd
done

