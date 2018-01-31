torun=$1

if [ "${torun}" == "ALK" ]
then
    ./process_alkphos.sh
    exit 0
fi

if [ "${torun}" == "HGB" ]
then
    ./process_hgb.sh
    exit 0
fi

if [ "${torun}" == "ELECTROLYTES" ]
then
    ./process_electrolytes.sh
    exit 0
fi

echo "COMMANDS: ALK, HGB, ELECTROLYTES"
