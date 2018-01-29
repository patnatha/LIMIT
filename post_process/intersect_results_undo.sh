tolistpath=$1

eval "rm ${tolistpath}/*joined.Rdata"
eval "mv ${tolistpath}/med/*med.Rdata" "${tolistpath}."
eval "mv ${tolistpath}/icd/*icd.Rdata" "${tolistpath}."
eval "mv ${tolistpath}/lab/*lab.Rdata" "${tolistpath}."

