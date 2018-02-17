source ../basedir.sh
tolistpath=$1
post_process_dir
for tdir in $prepdirs
do
    echo $tdir
    #Execute the combination command
    thecmd="Rscript exclude_combined.R --input $tdir/"
    eval $thecmd
    #echo $thecmd

    #Move the joined to their own separate directory
    eval "mkdir -p ${tdir}/joined"
    eval "mv ${tdir}/*joined.Rdata" "${tdir}/joined/."
done

