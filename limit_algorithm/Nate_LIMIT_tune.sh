source ../basedir.sh
toswitch="TUNEUP"
switch_input

sed -i 's/ppn=[0-9]\+/ppn=4/' Nate_LIMIT.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' Nate_LIMIT.pbs

declare -a criticalHampels=("0.5" "1.0" "2.0" "3.0")
declare -a criticalPs=("0.05" "0.1" "0.2")
declare -a criticalProps=("0" "0.005" "0.025" "0.05" "0.01")
declare -a day_time_offset_posts=("360" "180" "120" "90" "60" "30" "5")
declare -a day_time_offset_pres=("360" "180" "120" "90" "60" "30" "5")
declare -a code_switch=("icd" "med" "lab")

#Calculate number of permutations
curOff=$((${#day_time_offset_pres[@]} * ${#day_time_offset_posts[@]} * ${#criticalProps[@]} * ${#criticalPs[@]} * ${#criticalHampels[@]} * ${#code_switch[@]}))
echo "TO TUNE: "$curOff

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

if [ $stopIt == "TRUE" ]
then
    exit
fi

theCounter=0
for tfile in `find ${preparedir} | grep selected | sort`
do  
    #Get the base filename
    tfbase=`basename $tfile`
    echo $tfbase
    fileCnt=$((fileCnt + 1))

    #Get and build the output directry
    outdirname=`dirname $tfile`
    outdirname=${outdirname/"prepared_data"/"limit_results"}
    mkdir -p ${outdirname}

    #For this file build the basename for output
    tfbase=${tfbase/".Rdata"/"_"}
    outfilename="${tfbase}"

    for (( h=0; h<${#code_switch[@]}; h++ ));
    do
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
                            toutfilename="${outfilename}H${criticalHampels[$i]}_P${criticalPs[$j]}_PROP${criticalProps[$k]}_POST_${day_time_offset_posts[$l]}_PRE${day_time_offset_pres[$m]}_${code_switch[$h]}"
                           
                            #Check to see if the file already exists on disk
                            fileExist=`find ${outdirname} | grep "${toutfilename}" | wc -l`
                            if [ $fileExist == "1" ]
                            then
                                continue
                            fi
                            
                            #Build all the parameters
                            parameters="--input ${tfile} --code ${code_switch[$h]} --output ${outdirname} --name ${toutfilename} --critical-hampel ${criticalHampels[$i]} --critical-p-value ${criticalPs[$j]} --critical-proportion ${criticalProps[$k]} --day-time-offset-post ${day_time_offset_posts[$l]} --day-time-offset-pre ${day_time_offset_pres[$m]}"

                            #Submit the job
                            cmd="qsub Nate_LIMIT.pbs -F \"$parameters\""
                            eval $cmd
 
                            #Don't let the script submit more than necessary
                            theCounter=$((theCounter + 1))
                            if [ $theCounter == $curOff ]
                            then
                                echo "Submitted max number of jobs: $theCounter"
                                exit
                            fi
                        done
                    done
                done
            done
        done
    done
done

