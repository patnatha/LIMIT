source ../basedir.sh
tolistpath=$1
post_process_dir
for tdir in $prepdirs
do
    #Create output directory for graphs
    eval "mkdir -p ${tdir}/graphs/"

    #Creat output file for analysis results
    outputFile="${tdir}/analysis_results.csv"
    rm -f ${outputFile}
    echo "File, Result Code, Group, Sex, Race, Start Days, End Days, Selection, Pre-LIMIT Count,  Post-Limit ICD Count, Post-Limit Med Count, Post-Limit Lab Count, ICD-Lab-Med Joined Count, Post-Combined Count, Post-Horn Count, Pre-LIMIT 2.5%, Pre-LIMIT 5%, Pre-LIMIT 95%, Pre-LIMIT 97.5%, Post-LIMIT 2.5%, Post-LIMIT 5%, Post-LIMIT 95%, Post-LIMIT 97.5%, Boot Low Low 95%, Boot Low High95%, Boot High Low 95%, Boot High High 95%, Boot Low Low 90%, Boot Low High 90%, Boot High Low 90%, Boot High High 90%" > ${outputFile}

    #List the files to run
    theCnt=0
    preplist=`find $tdir | grep -P 'combined.*Rdata' | sort`
    for tfile in $preplist;
    do
        thecmd="Rscript analyze_results.R --input $tfile"
        eval $thecmd
    done
done

