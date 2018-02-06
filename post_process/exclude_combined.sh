tolistpath=$1

thecmd="Rscript exclude_combined.R --input $tolistpath"
eval $thecmd

eval "mkdir -p ${tolistpath}joined"
eval "mv ${tolistpath}*joined.Rdata" "${tolistpath}joined/."

