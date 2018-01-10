source ../basedir.sh

#Set the output directory
outdir="${preparedir}alk_phos_5_years/"
mkdir -p $outdir

#Set basic variables
incGrp="all"
therace="all"
indir="alk_phos_5_years"

thesex="male"
    theage="0D_14D"
    run_em_prepare

    theage="14D_712D"
    run_em_prepare

    theage="2Y_10Y"
    run_em_prepare

    theage="10Y_13Y"
    run_em_prepare

    theage="13Y_15Y"
    run_em_prepare

    theage="15Y_17Y"
    run_em_prepare

    theage="17Y_19Y"
    run_em_prepare

thesex="female"
    theage="0D_14D"
    run_em_prepare

    theage="14D_712D"
    run_em_prepare

    theage="2Y_10Y"
    run_em_prepare

    theage="10Y_13Y"
    run_em_prepare

    theage="13Y_15Y"
    run_em_prepare

    theage="15Y_17Y"
    run_em_prepare

    theage="17Y_19Y"
    run_em_prepare

