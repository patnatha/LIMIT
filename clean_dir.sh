if [ ! -z $1 ]
then
    deleteOverRide=$1
fi

test_empty_dirs(){
    deletedSuccess=0
    for tfile in `ls ./${batchoutput} 2> /dev/null`
    do
        deleteFile="TRUE"
        grepRes=$(grep -nH "ERROR\|Error" ${tfile})
        if [[ $grepRes != "" ]]
        then
            deleteFile="FALSE"
        fi
        echo "$grepRes"
        echo "++++++++++"

        if [[ $deleteFile == "TRUE" ]] || [[ $deleteOverRide == "FORCE" ]]
        then
            rm $tfile
            deletedSuccess=$((deletedSuccess + 1))
        fi
    done
    echo "${batchoutput} - DELETED: $deletedSuccess"
}

batchoutput="Nate_LIMIT.o*"
test_empty_dirs

batchoutput="prepare_data.o*"
test_empty_dirs

batchoutput="prepare_selection.o*"
test_empty_dirs

batchoutput="tune_it_up.o*"
test_empty_dirs

batchoutput="intersect_tuneup.o*"
test_empty_dirs

batchoutput="post_process.o*"
test_empty_dirs

batchoutput="tune_intersect.o*"
test_empty_dirs

batchoutput="prepare_to_pair.o*"
test_empty_dirs

batchoutput="pair_values.o*"
test_empty_dirs

batchoutput="combine_pairs.o*"
test_empty_dirs

batchoutput="analyze_group.o*"
test_empty_dirs

batchoutput="count_files.o*"
test_empty_dirs

batchoutput="tune_exclude.o*"
test_empty_dirs

batchoutput="intersect_group.o*"
test_empty_dirs

batchoutput="sample_exclude.o*"
test_empty_dirs
