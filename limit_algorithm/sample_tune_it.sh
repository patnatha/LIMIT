source ../basedir.sh
toswitch=$1
switch_input

#Set the parameters for the program
sed -i 's/ppn=[0-9]\+/ppn=4/' Nate_LIMIT.pbs
sed -i 's/pmem=[0-9]\+gb/pmem=4gb/' Nate_LIMIT.pbs
sed -i 's/walltime=[0-9]\+\:[0-9]\+\:[0-9]\+/walltime=3:00:00/' Nate_LIMIT.pbs

declare -a sample_sizes=("100000" "75000" "50000" "40000" "30000" "20000" "10000" "8000" "6000" "4000" "3000" "2000" "1000" "500" "100" "50")

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

    for (( i=0; i<${#sample_sizes[@]}; i++ ));
    do
        toutfilename="${outfilename}${sample_sizes[$i]}"
        parameters="--input ${tfile} --code all --output ${outdirname} --name ${toutfilename} --sample ${sample_sizes[$i]}"

        cmd="qsub Nate_LIMIT.pbs -F \"$parameters\""
        eval $cmd
    done 
done

