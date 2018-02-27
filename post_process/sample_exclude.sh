source ../basedir.sh
toswitch=$1
switch_input
tolistpath=$limitdir
post_process_dir

declare -a sample_sizes=("100000" "75000" "50000" "40000" "30000" "20000" "10000" "8000" "6000" "4000" "3000" "2000" "1000" "500" "100" "50")

theCounter=0
for tdir in $prepdirs
do
    for (( i=0; i<${#sample_sizes[@]}; i++ ));
    do
        toutfilename="${sample_sizes[$i]}_joined.Rdata"
        fileCnts=`ls ${tdir}/*${toutfilename}* | wc -l`
        echo "${toutfilename}: $fileCnts"

        thecmd="Rscript exclude_combined.R --input $tdir/ --prefix \"${toutfilename}\""
        #echo $thecmd
        eval $thecmd
    done
done

