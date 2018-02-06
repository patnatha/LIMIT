torun=$1

if [ "${torun}" == "ALK" ]
then
    ./process_alkphos.sh
    exit 0
fi

if [ "${torun}" == "MAYO_ALK" ]
then
    ./process_mayo_alkphos.sh
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

if [ "${torun}" == "BMP" ]
then
    ./process_bmp.sh
    exit 0
fi

if [ "${torun}" == "BILI" ]
then
    ./process_bilirubin.sh
    exit 0
fi

echo "COMMANDS: ALK, BILI, BMP, ELECTROLYTES, HGB, MAYO_ALK"
