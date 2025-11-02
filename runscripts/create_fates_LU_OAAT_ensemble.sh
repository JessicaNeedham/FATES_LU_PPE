#!/bin/bash

run_elm_fates(){

    export COMPSET='HIST_DATM%CRUJRA2024_CLM60%FATES_SICE_SOCN_SROF_SGLC_SWAV_SESP'
    export RES="ne16pg3_tn14"   # "f45_f45_mg37" # ne16pg3_tn14, #f19_g17, ne30pg3_tn14, f45_f45_mg37, ne16pg3_tn14
    export MACH='betzy'
    export PROJECT='nn9188k'

    export USER='jessica'
    export workpath='/cluster/work/users/jessica'
    export paramdir='/cluster/home/jessica/NCSrevise/paramfiles'
    
    export PARAM=$1
    export MINMAX=$2
    
    export TAG=noresm-fates_LU_OAAT_${PARAM}_${MINMAX}
    export CASEROOT=$workpath/ncsrevise_runs/OAAT/
    export CIMEROOT=$workpath/noresm-ncsrevise/CTSM/cime/scripts

    cd ${CIMEROOT}

    export CIME_HASH=`git log -n 1 --pretty=%h`
    export NorESM_CTSM_HASH=`(cd ../..;git log -n 1 --pretty=%h)`
    export FATES_HASH=`(cd src/fates;git log -n 1 --pretty=%h)`
    export GIT_HASH=N${NorESM_CTSM_HASH}-F${FATES_HASH}	
    export CASE_NAME=${CASEROOT}/${TAG}.${GIT_HASH}.`date +"%Y-%m-%d"`


    # REMOVE EXISTING CASE DIRECTORY IF PRESENT 
    rm -rf ${CASE_NAME}

    # CREATE THE CASE
    ./create_newcase --case=${CASE_NAME} --res=${RES} --compset=${COMPSET} --mach=${MACH} --project=${PROJECT} --run-unsupported

    cd ${CASE_NAME}

    ./xmlchange STOP_N=50
    ./xmlchange STOP_OPTION=nyears
    ./xmlchange REST_N=25
    ./xmlchange REST_OPTION=nyears
    ./xmlchange RESUBMIT=0
    ./xmlchange DEBUG=FALSE


    # Transient CO2, constant early 20th C climate
    ./xmlchange RUN_STARTDATE=1851-01-01
    ./xmlchange CLM_ACCELERATED_SPINUP=off
    ./xmlchange DATM_YR_START=1901
    ./xmlchange DATM_YR_END=1920
    ./xmlchange DATM_YR_ALIGN=1851
    ./xmlchange DATM_PRESAERO=clim_1850
    ./xmlchange CLM_CO2_TYPE=diagnostic
    ./xmlchange DATM_CO2_TSERIES=20tr
    ./xmlchange CCSM_BGC=CO2A

    ./xmlchange --subgroup case.run JOB_WALLCLOCK_TIME=24:00:00
    ./xmlchange --subgroup case.st_archive JOB_WALLCLOCK_TIME=00:30:00

    ./xmlchange EXEROOT=
    ./xmlchange BUILD_COMPLETE=TRUE
    
    ./xmlchange RUNDIR=${CASE_NAME}/run

    cat >>  user_nl_clm <<EOF
do_transient_lakes=.false.
do_transient_urban=.false.
finidat=''
fates_paramfile='/cluster/home/jessica/NCSrevise/paramfiles/OAAT/fates_params_api.40.0.0_14pft_c250807_noresm_v250812__noresm_v25a_fates_${PARAM}_${MINMAX}.nc'
paramfile='/cluster/shared/noresm/inputdata/lnd/clm2/paramdata/ctsm60_params.200905_v25u.nc'
use_fates_sp=.false.
use_fates_nocomp=.true.
use_fates_fixed_biogeog=.true.
fates_stomatal_model='medlyn2011'
fates_radiation_model='twostream'
fates_leafresp_model='ryan1991'
use_fates_luh=.true.
use_fates_lupft=.true.
fates_harvest_mode='luhdata_area'
use_fates_potentialveg=.false.
fates_lu_transition_logic=1
fluh_timeseries='/cluster/shared/noresm/inputdata/LU_data_CMIP7/LUH2_states_transitions_management.timeseries_ne16_hist_steadystate_1850_2025-10-24_cdf5.nc'
flandusepftdat='/cluster/shared/noresm/inputdata/LU_data_CMIP7/fates_landuse_pft_map_to_surfdata_ne16np4_251024_cdf5.nc'
fates_spitfire_mode=4
hist_empty_htapes=.true.
hist_fincl1='FCO2', 'FATES_GPP_LU', 'FATES_DISTURBANCE_RATE_MATRIX_LULU', 'FATES_TRANSITION_MATRIX_LULU', 'FATES_BURNEDAREA_LU', 
'FATES_VEGC_LU', 'FATES_PATCHAREA_LU', 'FATES_NPP_LU', 'FATES_DISTURBANCE_RATE_LOGGING', 
'FATES_VEGC_ABOVEGROUND', 'FATES_VEGC', 'FATES_FRACTION', 'FATES_GPP','FATES_NEP','FATES_AUTORESP', 'FATES_HET_RESP', 'QVEGE',
 'QVEGT','QSOIL','EFLX_LH_TOT','FSH','FSR', 'FSDS','FSA','FIRE','FLDS','FATES_LAI', 'FATES_VEGC_PF', 'FATES_NPLANT_SZ',
'FATES_SECONDARY_AREA_ANTHRO_AP','FATES_SECONDARY_AREA_AP','FATES_PRIMARY_AREA_AP','FATES_NPP_LU','FATES_GPP_LU',
'TSA', 'SNOW', 'TLAI', 'FLDS', 'LAISUN', 'FSH', 'EFLX_LH_TOT', 'H2OSNO', 'FSDS', 'FSR', 'FSA', 'TOTSOMC_1m',
'DSTFLXT', 'FATES_NPP', 'FATES_LAI','FATES_AREA_PLANTS', 'FATES_LEAFC', 
'FATES_MORTALITY_CFLUX_CANOPY', 'BTRAN', 'FATES_NEP', 'FSNO', 'FATES_BURNFRAC', 
'TOTSOILICE', 'TOTSOILLIQ', 'TWS', 'FATES_GRAZING', 'FATES_FIRE_CLOSS', 'TOT_WOODPROC_LOSS', 
'FATES_HARVEST_WOODPROD_C_FLUX', 'FATES_LUCHANGE_WOODPROD_C_FLUX', 

EOF

    ./case.setup
    ./case.submit

}


cd /cluster/home/jessica/NCSrevise/paramfiles/OAAT/

echo 'number of runs to set up: '
echo | ls | wc -l

for file in *.nc; do

    [[ -f "$file" ]] || continue

    fname="$file"
    # Extract the part after 'v25a_'                                                                             
    segment="${fname#*v25a_}"
    # Remove extension                                                                                           
    segment="${segment%.nc}"
    # Split by underscores                                                                                       
    IFS='_' read -r -a arr <<< "$segment"
    n=${#arr[@]}
    if (( n >= 2 )); then
        # key1: all but the last element, joined by underscores                                                  
        param="${arr[@]:0:n-1}"
        param="${key1// /_}"
        # key2: last element                                                                                     
        minmax="${arr[n-1]}"
        echo "$fname -> $param $minmax"
	run_elm_fates $param $minmax
    else
        echo "$fname -> Not matched"
    fi

done
    
