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
    echo "File, Result Code, Group, Sex, Race, Start Days, End Days, Selection, Pre-LIMIT Count,  LIMIT ICD Count, LIMIT Med Count, LIMIT Lab Count, Joined Count, Combined Count, Horn Count, Pre-LIMIT 2.5%, Pre-LIMIT 5%, Pre-LIMIT 95%, Pre-LIMIT 97.5%, RI, RI Method, RI Low, RI High, RI, RI Method, CI Low Low, CI Low High, CI High Low, CI High High, CI, CI Method, GS Ref Low, GS Ref High, GS Ref Source, GS Conf Low Low, GS Conf Low High, GS Conf High Low, GS Conf High High, GS Conf Source" > ${outputFile}

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

    exit
done

