source ../basedir.sh
toswitch=$1
switch_input
tolistpath=$limitdir
post_process_dir

analyzeWhich="combined"
if [ ! -z $2 ]
then
    if [[ "$2" == "joined" ]] || [[ "$2" == "icd" ]] || [[ "$2" == "med" ]] || [[ "$2" == "lab" ]]
    then
        analyzeWhich=$2
    fi
fi

for tdir in $prepdirs
do
    echo "ANALYZE: "$tdir

    #Create output directory for graphs
    eval "mkdir -p ${tdir}/graphs/"

    #Create output file for analysis results
    outputFile="${tdir}/analysis_results_${analyzeWhich}.csv"
    rm -f ${outputFile}
    echo -n "File, Result Code, Group, Sex, Race, Start Days, End Days, Selection, LIMIT Params, " > ${outputFile}
    echo -n "Pre-LIMIT Count,  LIMIT ICD Count, LIMIT Med Count, LIMIT Lab Count, " >> ${outputFile}
    echo -n "Joined Count, " >> ${outputFile}
    if [[ "$analyzeWhich" == "combined" ]]
    then
        
        echo -n "Combined Count, " >> ${outputFile}
    fi
    echo -n "Horn Count, " >> ${outputFile}
    echo -n "Pre-LIMIT Low, Pre-LIMIT High, RI, RI Method, " >> ${outputFile}
    echo -n "RI Low, RI High, RI, RI Method, " >> ${outputFile}
    echo -n "CI Low Low, CI Low High, CI High Low, CI High High, CI, CI Method, " >> ${outputFile}
    echo -n "GS Ref Low, GS Ref High, GS Ref Source, " >> ${outputFile}
    echo -n "GS Conf Low Low, GS Conf Low High, " >> ${outputFile}
    echo -n "GS Conf High Low, GS Conf High High, GS Conf Source, " >> ${outputFile}
    echo -n "Original Ratio, LIMIT Ratio, " >> ${outputFile}
    echo "Low in CI, High in CI" >> ${outputFile}

    #Find some files to run
    preplist=`find $tdir | grep "${analyzeWhich}.Rdata" | sort`

    #Run all the files in parallel
    if [[ ${#preplist} == 0 ]]
    then
        continue
    fi
    parOut=`parallel -j8 Rscript analyze_results.R --input {} --ref ${refCodes} ::: ${preplist}`
    appendLine=`echo -e "$parOut" | grep "ANALYSIS_RESULTS" | cut -d ":" -f2 | cut -d "\"" -f1 | sort`
    echo "${appendLine}" >> ${outputFile}
    continue
 
    #Iterate over the files 
    theCnt=0
    for tfile in $preplist;
    do
        {
            echo "FILE: $tfile"
            theCnt=$((theCnt + 1))
            theCmd="Rscript analyze_results.R --input ${tfile} --ref ${refCodes} 2> /dev/null"
            output=`eval $theCmd`
            appendLine=`echo -e "$output" | grep "ANALYSIS_RESULTS" | cut -d ":" -f2`
            echo "$appendLine" >> ${outputFile}
        } || {
            #Debugging area
            continue
            exit
        }
    done
done

