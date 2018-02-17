source ../basedir.sh
toswitch="TUNEUP"
switch_input
tolistpath=$limitdir
post_process_dir

for tdir in $prepdirs
do
    #Create the output directory for the old files
    eval "mkdir -p ${tdir}/joined"

    for (( i=0; i<${#criticalHampels[@]}; i++ ));
    do
        for (( j=0; j<${#criticalPs[@]}; j++ ));
        do
            for (( k=0; k<${#criticalProps[@]}; k++ ));
            do
                for (( l=0; l<${#day_time_offset_posts[@]}; l++ ));
                do
                    for (( m=0; m<${#day_time_offset_pres[@]}; m++ ));
                    do
                        #build the output name
                        toutfilename="${outfilename}H${criticalHampels[$i]}_P${criticalPs[$j]}_PROP${criticalProps[$k]}_POST_${day_time_offset_posts[$l]}_PRE${day_time_offset_pres[$m]}"
                        fileCnts=`ls ${tdir}/*${toutfilename}* | wc -l`
                        echo "${toutfilename}: $fileCnts"
                    
                        thecmd="Rscript exclude_combined.R --input $tdir/ --prefix ${toutfilename}"
                    done
                done
            done
        done
    done

    #Move all the old files to their own directory
    #eval "mv ${tdir}/*joined.Rdata" "${tdir}/joined/."
done

