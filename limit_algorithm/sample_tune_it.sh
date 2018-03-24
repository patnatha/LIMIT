source ../basedir.sh
toswitch=$1
switch_input

#Set the parameters for the program
sed -i 's/ppn=[0-9]\+/ppn=4/' Nate_LIMIT.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' Nate_LIMIT.pbs
sed -i 's/walltime=[0-9]\+\:[0-9]\+\:[0-9]\+/walltime=3:00:00/' Nate_LIMIT.pbs

theCounter=0
for tfile in `find ${preparedir} | grep selected | sort`
do
    #For this file build the basename for output
    tfbase=`basename $tfile`
    tfbase=${tfbase/".Rdata"/"_"}
    outfilename="${tfbase}"

    outdirname=`dirname $tfile`
    outdirname=${outdirname/"prepared_data"/"limit_results"}
    mkdir -p ${outdirname}

    submitted=0
    for (( i=0; i<${#sample_sizes[@]}; i++ ));
    do
        toutfilename="${outfilename}${sample_sizes[$i]}"
      
        #Find all the files with the prefix of the file to run
        checkFile="find ${outdirname}/${toutfilename}* -type f 2> /dev/null"
        checkedFiles=`eval $checkFile`

        filesExist=0
        joinedExists=0
        combinedExists=0
        for cFile in $checkedFiles
        do  
            joinedExists=`echo $cFile | grep joined | wc -l`
            combinedExists=`echo $cFile | grep combined | wc -l`
            if [[ $joinedExists == 1 ]] || [[ $combinedExists == 1 ]]
            then
                break
            fi
            filesExist=$((filesExist + 1))
        done
        
        #If the output files already exist then skip this iteration                        
        if [[ $filesExist > 2 ]] || [[ $joinedExists == 1 ]] || [[ $combinedExists == 1 ]]
        then
            continue
        fi

        #Build the command and submit it
        parameters="--input ${tfile} --code all --output ${outdirname} --name ${toutfilename} --sample ${sample_sizes[$i]}"
        cmd="qsub Nate_LIMIT.pbs -F \"$parameters\""
        output=`eval $cmd`
        submitted=$((submitted + 1))
    done 
    echo "${tfile}: ${submitted} jobs"
done

