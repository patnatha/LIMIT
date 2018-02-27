source ../basedir.sh
toswitch=$1
switch_input
tolistpath=$limitdir
post_process_dir

theCounter=0
for tdir in $prepdirs
do
    for (( i=0; i<${#sample_sizes[@]}; i++ ));
    do
        toutfilename="${sample_sizes[$i]}_joined.Rdata"
        fileCnts=`ls ${tdir}/*${toutfilename}* | wc -l`
        echo "${toutfilename}: $fileCnts"

        thecmd="Rscript exclude_combined.R --input $tdir/ --prefix \"${toutfilename}\""
        eval $thecmd
    done

    eval "mv ${tdir}/*joined.Rdata" "${tdir}/joined/."
done

