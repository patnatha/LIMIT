source ../basedir.sh
toswitch=$1
switch_input
tolistpath=$limitdir
post_process_dir

runInPlace="NOPE"
if [ ! -z $2 ] && [[ "$2" == "inplace" ]]
then
    runInPlace="YASE"
fi

for tdir in $prepdirs
do
    echo "ANALYZE: "$tdir

    #Create output directory for graphs
    eval "mkdir -p ${tdir}/graphs/"

    #Creat output file for analysis results
    outputFile="${tdir}/analysis_results.csv"
    rm -f ${outputFile}
    echo -n "File, Result Code, Group, Sex, Race, Start Days, End Days, Selection, LIMIT Params, " > ${outputFile}
    echo -n "Pre-LIMIT Count,  LIMIT ICD Count, LIMIT Med Count, LIMIT Lab Count, Joined Count, Combined Count, Horn Count, " >> ${outputFile}
    echo -n "Pre-LIMIT Low, Pre-LIMIT High, RI, RI Method, RI Low, RI High, RI, RI Method, " >> ${outputFile}
    echo -n "CI Low Low, CI Low High, CI High Low, CI High High, CI, CI Method, " >> ${outputFile}
    echo -n "GS Ref Low, GS Ref High, GS Ref Source, " >> ${outputFile}
    echo -n "GS Conf Low Low, GS Conf Low High, GS Conf High Low, GS Conf High High, GS Conf Source, " >> ${outputFile}
    echo "Original Ratio, LIMIT Ratio" >> ${outputFile}

    #List the files to run
    theCnt=0
    preplist=`find $tdir | grep -P 'combined.*Rdata' | sort`
    for tfile in $preplist;
    do
        {
            Rscript analyze_results.R --input ${tfile} 
        } || {
            exit
        }
    done
done

