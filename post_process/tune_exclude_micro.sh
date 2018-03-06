source ../basedir.sh
toswitch=$1
switch_input
tolistpath=$limitdir
post_process_dir

declare -a criticalHampels=("2.0" "3.0") #"0.5" "1.0"
declare -a criticalPs=("0.1" "0.2") #"0.05"
declare -a criticalProps=("0" "0.005") #"0.01" "0.025" "0.05"
declare -a day_time_offset_posts=("54750" "360" "180" "5" "0") #"75" "30"
declare -a day_time_offset_pres=("54750" "360" "180" "5" "0") #"75" "30"

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
                        toutfilename="H${criticalHampels[$i]}_P${criticalPs[$j]}_PROP${criticalProps[$k]}_POST${day_time_offset_posts[$l]}_PRE${day_time_offset_pres[$m]}_joined.Rdata"
                        fileCnts=`ls ${tdir}/*${toutfilename}* | wc -l`
                        echo "${toutfilename}: $fileCnts"
                    
                        if [[ $fileCnts > 0 ]]
                        then
                            thecmd="Rscript exclude_combined.R --input $tdir/ --prefix \"${toutfilename}\""
                            eval $thecmd
                        fi
                    done
                done
            done
        done
    done
done

