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
    ./create_newcase --case=${CASE_NAME} --res=${RES} --compset=${COMPSET} --mach=${MACH} --project=${PROJECT} --run-unsupported --pecount L

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

    ./xmlchange EXEROOT=/cluster/work/users/jessica/ncsrevise_runs/noresm-fates-ne16-LU-PPE-AD-spinup.N1048fbece-Fab73a7eb7.2026-01-06/bld
    ./xmlchange BUILD_COMPLETE=TRUE
    
    ./xmlchange RUNDIR=${CASE_NAME}/run

    # turn on Megan
    ./xmlchange CLM_BLDNML_OPTS="-bgc fates -megan"

    cat >>  user_nl_clm <<EOF
do_transient_lakes=.false.
do_transient_urban=.false.
finidat=''
fates_paramfile='/cluster/home/jessica/NCSrevise/paramfiles/OAAT/fates_params_LU_PPE_${PARAM}_${MINMAX}.nc'
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
fluh_timeseries='/cluster/shared/noresm/inputdata/LU_data_CMIP7/LUH2_timeseries_to_surfdata_ne16np4_251106_cdf5.nc'
flandusepftdat='/cluster/shared/noresm/inputdata/LU_data_CMIP7/fates_landuse_pft_map_to_surfdata_ne16np4_251106_cdf5.nc'
fates_spitfire_mode=4
hist_empty_htapes=.true.
hist_fincl1='BTRAN', 'DSTFLXT', 'EFLX_LH_TOT', 'FATES_AREA_PLANTS', 'FATES_AUTORESP', 'FATES_BURNEDAREA_LU', 'FATES_BURNFRAC', 'FATES_DISTURBANCE_RATE_LOGGING', 
'FATES_DISTURBANCE_RATE_MATRIX_LULU', 'FATES_FIRE_CLOSS', 'FATES_FRACTION', 'FATES_GPP', 'FATES_GPP_LU', 'FATES_GRAZING', 'FATES_HET_RESP',
 'FATES_LAI', 'FATES_LAI_PF', 'FATES_LEAFC', 'FATES_LITTER_AG_CWD_EL', 'FATES_LITTER_AG_FINE_EL', 'FATES_LITTER_BG_CWD_EL', 'FATES_LITTER_BG_FINE_EL', 'FATES_LUCHANGE_WOODPROD_C_FLUX', 'FATES_MORTALITY_CFLUX_CANOPY', 'FATES_NEP', 'FATES_NPLANT_SZ', 'FATES_NPP', 'FATES_NPP_LU', 'FATES_PATCHAREA_LU',
 'FATES_PRIMARY_AREA_AP', 'FATES_SECONDARY_AREA_ANTHRO_AP', 'FATES_SECONDARY_AREA_AP', 'FATES_TRANSITION_MATRIX_LULU', 'FATES_VEGC',
 'FATES_VEGC_ABOVEGROUND','FATES_VEGC_ABOVEGROUND_SZ', 'FATES_VEGC_LU', 'FATES_VEGC_PF', 'FCO2', 'FIRE', 'FLDS', 'FSA', 'FSDS',
 'FSH', 'FSNO', 'FSR', 'H2OSNO', 'LAISUN', 'PROD100C', 'PROD10C', 'QSOIL', 'QVEGE', 'QVEGT', 'RAIN', 'SNOW', 'TLAI', 'TOTSOILICE', 
'TOTSOILLIQ', 'TOTSOMC', 'TOTSOMC_1m', 'TSA', 'TWS', 'FATES_MORTALITY_CSTARV_CFLUX_PF', 'FATES_MORTALITY_FIRE_CFLUX_PF',
 'FATES_MORTALITY_HYDRAULIC_CFLUX_PF', 'FATES_DDBH_CANOPY_SZ', 'FATES_DDBH_USTORY_SZ', 'FATES_MORTALITY_CANOPY_SZ', 
'FATES_MORTALITY_USTORY_SZ', 'FATES_MORTALITY_TERMINATION_SZ', 'FATES_MORTALITY_IMPACT_SZ', 'FATES_MORTALITY_CSTARV_SZ',
 'FATES_MORTALITY_HYDRAULIC_SZ','FATES_MORTALITY_BACKGROUND_SZ', 'FATES_MORTALITY_SENESCENCE_SZ', 'FATES_MORTALITY_FREEZING_SZ',
 'FATES_NPLANT_CANOPY_SZ','FATES_NPLANT_USTORY_SZ', 'FATES_STOREC', 'FATES_SAPWOODC', 'FATES_FROOTC', 'FATES_REPROC',
'FATES_STRUCTC', 'FATES_STRUCT_ALLOC_CANOPY_SZ','FATES_SAPWOOD_ALLOC_CANOPY_SZ', 'FATES_SEED_ALLOC_CANOPY_SZ', 'FATES_FROOT_ALLOC_CANOPY_SZ', 
'FATES_STORE_ALLOC_CANOPY_SZ', 'FATES_LEAF_ALLOC_CANOPY_SZ', 'FATES_MEAN_95PCTILE_HEIGHT', 'FATES_RECRUITMENT_PF'
EOF

    cat >> user_nl_datm_streams <<EOF
co2tseries.20tr:datafiles=/cluster/shared/noresm/inputdata/atm/datm7/CO2/fco2_datm_global_simyr_1750-2024_CMIP6_c251015.nc
co2tseries.20tr:year_last=2024
EOF

    
    ./case.setup
    ./case.submit

}


cd /cluster/home/jessica/NCSrevise/paramfiles/OAAT/

echo 'number of runs to set up: '
echo | ls | wc -l

files=(./*.nc)

for file in "${files[@]:1:5}"; do
    
    [[ -f "$file" ]] || continue

    fname="$file"
    # Extract the part after 'PPE_'
    segment="${fname#*PPE_}"
    # Remove extension                                                                                           
    segment="${segment%.nc}"
    # Split by underscores                                                                                       
    IFS='_' read -r -a arr <<< "$segment"
    n=${#arr[@]}
    if (( n >= 2 )); then
        # key1: all but the last element, joined by underscores                                                  
        param="${arr[@]:0:n-1}"
        param="${param// /_}"
        # key2: last element                                                                                     
        minmax="${arr[n-1]}"
        echo "$fname -> $param $minmax"
	run_elm_fates $param $minmax
    else
        echo "$fname -> Not matched"
    fi


done

