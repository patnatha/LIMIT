source ../basedir.sh
toswitch=$1
switch_input
tolistpath=$limitdir
post_process_dir

analyzeWhich="combined"
graphIt="F"
if [ ! -z $2 ]
then
    if [[ "$2" == "joined" ]] || [[ "$2" == "icd" ]] || [[ "$2" == "med" ]] || [[ "$2" == "lab" ]]
    then
        analyzeWhich=$2
    fi

    if [[ "$2" == "graph" ]]
    then
        graphIt="T"
    fi
fi

if [ ! -z $3 ] && [[ "$3" == "graph" ]]
then
    graphIt="T"
fi

for tdir in $prepdirs
do
    echo "ANALYZE: "$tdir $analyzeWhich

    #Create output directory for graphs
    eval "mkdir -p ${tdir}/graphs/"

    #Create output file for analysis results
    outputFile="${tdir}/analysis_results_${analyzeWhich}.csv"
    rm -f ${outputFile}
    echo -n "File, Result Code, Group, Sex, Race, Start Days, End Days, Selection, LIMIT Params, " > ${outputFile}
   
    echo -n "Pre-LIMIT Count, " >> ${outputFile}
    echo -n "LIMIT ICD Count, LIMIT Med Count, LIMIT Lab Count, " >> ${outputFile}
    echo -n "Joined Count, Combined Count, " >> ${outputFile}
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

    if [[ "$graphIt" == "T" ]]
    then
        parOut=`parallel -j16 Rscript analyze_results.R --input {} --ref ${refCodes} --graph ::: ${preplist}`
    else
        parOut=`parallel -j16 Rscript analyze_results.R --input {} --ref ${refCodes} ::: ${preplist}`
    fi
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
            if [[ "$graphIt" == "T" ]]
            then
                theCmd="Rscript analyze_results.R --input ${tfile} --ref ${refCodes} --graph 2> /dev/null"
            else
                theCmd="Rscript analyze_results.R --input ${tfile} --ref ${refCodes} 2> /dev/null"
            fi
            output=`eval $theCmd`

            #Append the analysis results
            appendLine=`echo -e "$output" | grep "ANALYSIS_RESULTS" | cut -d ":" -f2`
            echo "$appendLine" >> ${outputFile}
        } || {
            #Debugging area
            continue
            exit
        }
    done
done

