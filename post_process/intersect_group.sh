source ../basedir.sh
toswitch=$1
switch_input
tolistpath=${limitdir}
post_process_dir

for tdir in $prepdirs
do
    #Get the lists of them
    dirListing=`find ${tdir} -maxdepth 1 -type f | grep -P 'selected.*Rdata'`
    finarricd=`echo "$dirListing" | fgrep 'icd'`
    finarrmed=`echo "$dirListing" | fgrep 'med'`
    finarrlab=`echo "$dirListing" | fgrep 'lab'`

    #Make the output directories
    eval "mkdir -p ${tdir}/med"
    eval "mkdir -p ${tdir}/icd"
    eval "mkdir -p ${tdir}/lab"

    for icdfile in $finarricd;
    do
        #Get the icd file basename and dirname
        basefname=`basename ${icdfile} | sed 's/\(.*\)_.*/\1/'`
        basedirname=`dirname ${icdfile}`
        
        #Search the med and lab files for others like it
        medfile=`echo $finarrmed | fgrep -o "${basefname}_med.Rdata"`
        labfile=`echo $finarrlab | fgrep -o "${basefname}_lab.Rdata"`

        #If unable to find anything then skip it
        if [[ ${#icdfile} == 0 ]] || [[ ${#medfile} == 0 ]] || [[ ${#labfile} == 0 ]]
        then
            continue
        fi

        #Add the dirname
        medfile="${basedirname}/${medfile}"  
        labfile="${basedirname}/${labfile}"
 
        #Run the command 
        thecmd="Rscript intersect_results.R --icd $icdfile --med $medfile --lab $labfile"
        #echo $thecmd
        eval $thecmd

        #Move the file to appropiate directory
        eval `mv $icdfile ${tdir}/icd/.`
        eval `mv $medfile ${tdir}/med/.`
        eval `mv $labfile ${tdir}/lab/.`
    done
done

