source ../basedir.sh
tolistpath=$1
post_process_dir

for tdir in $prepdirs
do
    echo "=====Run these files?====="
    theCnt=0
    finarricd=()
    finarrmed=()
    finarrlab=()
    preplist=`find ${tdir} | grep -P 'selected.*Rdata'`
    for tfile in $preplist;
    do
        echo `basename $tfile`
        if [[ $tfile == *"icd"* ]];
        then
            finarricd+="${tfile}|"
        fi

        if [[ $tfile == *"med"* ]];
        then
            finarrmed+="${tfile}|"
        fi

        if [[ $tfile == *"lab"* ]];
        then
            finarrlab+="${tfile}|"
        fi
    done

    eval "mkdir -p ${tdir}/med"
    eval "mkdir -p ${tdir}/icd"
    eval "mkdir -p ${tdir}/lab"

    for tfile in $(echo $finarricd | tr "|" "\n");
    do
        basefname=`basename ${tfile} | sed 's/\(.*\)_.*/\1/'`
        for tfile2 in $(echo $finarrmed | tr "|" "\n");
        do
            basefname2=`basename ${tfile2} | sed 's/\(.*\)_.*/\1/'`
            if [ $tfile != $tfile2 ] && [ $basefname == $basefname2 ];
            then
                for tfile3 in $(echo $finarrlab | tr "|" "\n");
                do
                    basefname3=`basename ${tfile3} | sed 's/\(.*\)_.*/\1/'`
                    if [ $tfile != $tfile3 ] && [ $basefname == $basefname3 ];
                    then
                        thecmd="Rscript intersect_results.R --icd $tfile --med $tfile2 --lab $tfile3"
                        #echo $thecmd
                        eval $thecmd

                        #Move the file to appropiate directory
                        eval `mv $tfile ${tdir}/icd/.`
                        eval `mv $tfile2 ${tdir}/med/.`
                        eval `mv $tfile3 ${tdir}/lab/.`
                    fi
                done
            fi
        done
    done
done

