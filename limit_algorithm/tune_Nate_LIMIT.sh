source ../basedir.sh
toswitch=$1
switch_input

#Calculate number of permutations
curOff=$((${#day_time_offset_pres[@]} * ${#day_time_offset_posts[@]} * ${#criticalProps[@]} * ${#criticalPs[@]} * ${#criticalHampels[@]}))

#Check to see how many jobs are queued at the moment
queuedList=`qstat | grep \`whoami\` | grep Q | grep Nate_LIMIT | wc -l`
stopIt="FALSE"
if [ $queuedList != "0" ]
then
    echo "ERROR: there are currently $queuedList job(s) in the queue"
    stopIt="TRUE"
fi

#Check to see each job that is running
runningList=`qstat | grep \`whoami\` | grep R | grep Nate_LIMIT | wc -l`
if [ $runningList != "0" ]
then
    echo "ERROR: there are currently $runningList job(s) running"
    stopIt="TRUE"
fi

#Stop the script based on queue status
if [ $stopIt == "TRUE" ]
then
    exit
    #exi=1
fi

#Load up the already done files
filesComplete="./${toswitch}_files_complete.txt"
if [ ! -e "$filesComplete" ]
then
    touch $filesComplete
fi
resultsComplete=`cat ${filesComplete}`

theCounter=0
for tfile in `find ${preparedir} | grep selected | sort`
do
    #Set the parameters for the program
    sed -i 's/ppn=[0-9]\+/ppn=4/' Nate_LIMIT.pbs
    sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' Nate_LIMIT.pbs
    sed -i 's/walltime=[0-9]\+\:[0-9]\+\:[0-9]\+/walltime=3:00:00/' Nate_LIMIT.pbs

    #For this file build the basename for output
    tfbase=`basename $tfile`
    tfbase=${tfbase/".Rdata"/"_"}
    outfilename="${tfbase}"

    #Get the base filename and check to make sure not already done
    tfBaseDone=`echo $resultsComplete | grep $tfbase | wc -l`
    if [ $tfBaseDone == "1" ]
    then
        echo "DONE: ${tfbase}*"
        continue
    else
        echo "RUNNING: ${tfbase}*"
    fi

    #Get and build the output directry
    outdirname=`dirname $tfile`
    outdirname=${outdirname/"prepared_data"/"limit_results"}
    mkdir -p ${outdirname}

    #Keep track of skip cnt
    skipCnt=0

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
                        
                        #Find all the files with the prefix of the file to run
                        checkFile="find ${outdirname}/${toutfilename}* -type f 2> /dev/null"
                        checkedFiles=`eval $checkFile`

                        #Check to see if the coded runs are done
                        filesExist=0
                        joinedExists=0
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
                            skipCnt=$((skipCnt + 1))
                            if [[ $skipCnt == 1 ]]
                            then
                                echo -en "Skipped: ${skipCnt}"
                            fi
                            if [[ $((skipCnt % 100)) == 0 ]] || [[ $skipCnt == $curOff ]]
                            then
                                echo -en "\rSkipped: ${skipCnt}"
                            fi
                            continue
                        fi

                        #Finalize output build name 
                        toutfilename="${toutfilename}"
                        
                        #Build all the parameters
                        parameters="--input ${tfile} --code all --output ${outdirname} --name ${toutfilename} --critical-hampel ${criticalHampels[$i]} --critical-p-value ${criticalPs[$j]} --critical-proportion ${criticalProps[$k]} --day-time-offset-post ${day_time_offset_posts[$l]} --day-time-offset-pre ${day_time_offset_pres[$m]}"

                        #Submit the job
                        cmd="qsub Nate_LIMIT.pbs -F \"$parameters\""
                        OUTPUT=`eval $cmd`
 
                        #Don't let the script submit more than necessary
                        theCounter=$((theCounter + 1))
                        if [[ $theCounter == 0 ]]
                        then
                            echo -en "Submitted: ${theCounter} jobs"
                        elif [[ $theCounter > 0 ]]
                        then
                            echo -en "\rSubmitted: ${theCounter} jobs"
                        fi
                    done
                done
            done
        done
    done

    if [[ $theCounter > 0 ]]
    then
        echo -e "\rSubmitted all of current files job(s): $theCounter"
        exit
    elif [[ $theCounter == 0 ]]
    then
        echo -e "${resultsComplete}\n${tfbase}" > ${filesComplete}
        echo -e "\nCOMPLETE: ${tfbase}"
    fi
done

