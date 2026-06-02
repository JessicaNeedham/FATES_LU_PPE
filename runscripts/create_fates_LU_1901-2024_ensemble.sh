#!/bin/bash

restart_fates(){
    
    export COMPSET='HIST_DATM%CRUJRA2024_CLM60%FATES_SICE_SOCN_SROF_SGLC_SWAV_SESP'
    export RES=f19_g17
    export MACH='betzy'
    export PROJECT='nn9188k'

    export USER='jessica'
    export workpath='/cluster/work/users/jessica'

    export PARAM=$1
    export MINMAX=$2
    
    export TAG=noresm-fates_OAAT_1900-2023_${PARAM}_${MINMAX}
    export CASEROOT=$workpath/ncsrevise_runs/OAAT
    export CIMEROOT=$workpath/noresm-beta16/CTSM/cime/scripts
   
    cd ${CIMEROOT}

    export CIME_HASH=`git log -n 1 --pretty=%h`
    export NorESM_CTSM_HASH=`(cd ../..;git log -n 1 --pretty=%h)`
    export FATES_HASH=`(cd src/fates;git log -n 1 --pretty=%h)`
    export GIT_HASH=N${NorESM_CTSM_HASH}-F${FATES_HASH}	
    export CASE_NAME=${CASEROOT}/${TAG}.`date +"%Y-%m-%d"`

    # REMOVE EXISTING CASE DIRECTORY IF PRESENT 
    rm -rf ${CASE_NAME}

    # CREATE THE CASE
    ./create_newcase --case=${CASE_NAME} --res=${RES} --compset=${COMPSET} --mach=${MACH} --project=${PROJECT} --run-unsupported --pecount L

    cd ${CASE_NAME}

    ./xmlchange STOP_N=31
    ./xmlchange STOP_OPTION=nyears
    ./xmlchange REST_N=31
    ./xmlchange REST_OPTION=nyears
    ./xmlchange RESUBMIT=3
    ./xmlchange DEBUG=FALSE

    ./xmlchange RUN_STARTDATE=1901-01-01
    ./xmlchange CLM_ACCELERATED_SPINUP=off
    ./xmlchange DATM_YR_START=1901
    ./xmlchange DATM_YR_END=2023
    ./xmlchange DATM_YR_ALIGN=1901
    ./xmlchange CLM_CO2_TYPE=diagnostic
    ./xmlchange DATM_CO2_TSERIES=20tr
    ./xmlchange CCSM_BGC=CO2A
    ./xmlchange DATM_PRESAERO=hist

    # For real runs
    ./xmlchange --subgroup case.run JOB_WALLCLOCK_TIME=24:00:00
    ./xmlchange --subgroup case.st_archive JOB_WALLCLOCK_TIME=00:30:00

    ./xmlchange RUNDIR=${CASE_NAME}/run
    ./xmlchange BUILD_COMPLETE=TRUE
    ./xmlchange EXEROOT=/cluster/work/users/jessica/ncsrevise_runs/noresm-fates-f19-LU-PPE-1850-1900-control.2026-05-28/bld
    
    # turn on megan
    ./xmlchange CLM_BLDNML_OPTS="-bgc fates -megan"

    cat >>  user_nl_clm <<EOF
do_transient_lakes=.false.
do_transient_urban=.false.
irrigate=.false.
finidat='/cluster/work/users/jessica/ncsrevise_runs/OAAT/noresm-fates_LU_OAAT_${PARAM}_${MINMAX}.2026-05-28/run/noresm-fates_LU_OAAT_${PARAM}_${MINMAX}.2026-05-28.clm2.r.1901-01-01-00000.nc'
fates_paramfile='/cluster/home/jessica/NCSrevise/paramfiles/OAAT_json/fates_params_LU_PPE_${PARAM}_${MINMAX}.json'
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
fates_spitfire_mode=4
fluh_timeseries='/cluster/work/users/jessica/LU-PPE_files/LUH3_timeseries_850-2024_surfdata_1.9x2.5_c260514_smallToZero.nc'
flandusepftdat='/cluster/work/users/jessica/LU-PPE_files/fates_landuse_pft_surfdata_1.9x2.5_c260513.nc'
hist_empty_htapes=.true.
hist_fincl1='BTRAN', 'DSTFLXT', 'EFLX_LH_TOT', 'FATES_AREA_PLANTS', 'FATES_AUTORESP', 'FATES_BURNEDAREA_LU',
 'FATES_BURNFRAC','FATES_DISTURBANCE_RATE_LOGGING', 'FATES_FIRE_CLOSS',
 'FATES_FRACTION', 'FATES_GPP', 'FATES_GPP_LU', 'FATES_GRAZING', 'FATES_HET_RESP', 'FATES_LAI', 'FATES_LAI_PF',
 'FATES_LEAFC', 'FATES_LITTER_AG_CWD_EL', 'FATES_LITTER_AG_FINE_EL', 'FATES_LITTER_BG_CWD_EL',
 'FATES_LITTER_BG_FINE_EL', 'FATES_LUCHANGE_WOODPROD_C_FLUX', 'FATES_MORTALITY_CFLUX_CANOPY', 'FATES_NEP',
 'FATES_NPLANT_SZ', 'FATES_NPP', 'FATES_NPP_LU', 'FATES_PATCHAREA_LU',
 'FATES_PRIMARY_AREA_AP', 'FATES_SECONDARY_AREA_ANTHRO_AP', 'FATES_SECONDARY_AREA_AP',
 'FATES_VEGC', 'FATES_VEGC_ABOVEGROUND',
 'FATES_VEGC_LU', 'FCO2', 'FIRE', 'FLDS', 'FSA', 'FSDS', 'FSH', 'FSNO', 'FSR', 'H2OSNO',
 'LAISUN', 'PROD100C', 'PROD10C', 'QSOIL', 'QVEGE', 'QVEGT', 'RAIN', 'SNOW', 'TLAI', 'TOTSOILICE', 'TOTSOILLIQ',
 'TOTSOMC', 'TOTSOMC_1m', 'TSA', 'TWS', 'FATES_MORTALITY_CSTARV_CFLUX_PF', 'FATES_MORTALITY_FIRE_CFLUX_PF',
 'FATES_MORTALITY_HYDRO_CFLUX_PF',
'FATES_RECRUITMENT_PF', 'FATES_NPLANT_SZPF', 'FATES_GPP_PF', 'FATES_NPP_PF',
 'FATES_MEAN_95PCTILE_HEIGHT',
'FATES_NOCOMP_PATCHAREA_PF'
EOF

    cat >> user_nl_datm_streams <<EOF
co2tseries.20tr:datafiles=/cluster/work/users/jessica/ai4pex_inputs/inputs/CO2field/fco2_datm_global_simyr_1700-2024_TRENDY_c250625.nc
co2tseries.20tr:year_last=2024
co2tseries.20tr:year_first=1901
co2tseries.20tr:year_align=1901
EOF

    ./case.setup
    ./case.submit
}

cd /cluster/home/jessica/NCSrevise/paramfiles/OAAT_json/
echo 'number of runs to set up: '
echo | ls | wc -l

files=(./*.json)

i=0
for file in "/cluster/home/jessica/NCSrevise/paramfiles/OAAT_json"/*.json; do
    
    [[ -f "$file" ]] || continue

    fname="$file"
    # Extract the part after 'PPE_'
    segment="${fname#*PPE_}"
    # Remove extension                                                                                           
    segment="${segment%.json}"
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
	restart_fates $param $minmax
    else
        echo "$fname -> Not matched"
    fi

    ((i += 1))

done
