#!/bin/bash

export COMPSET='1850_DATM%CRUJRA2024_CLM60%FATES_SICE_SOCN_SROF_SGLC_SWAV_SESP'
export RES="ne16pg3_tn14"   # "f45_f45_mg37" # ne16pg3_tn14, #f19_g17, ne30pg3_tn14, f45_f45_mg37, ne16pg3_tn14
export MACH='betzy'
export PROJECT='nn9188k'

export USER='jessica'
export workpath='/cluster/work/users/jessica'
export paramdir='/cluster/home/jessica/NCSrevise/paramfiles'

export TAG='noresm-fates_AD_spinup_LU'
export CASEROOT=$workpath/ncsrevise_runs
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
 
./xmlchange STOP_N=100
./xmlchange STOP_OPTION=nyears
./xmlchange REST_N=50
./xmlchange REST_OPTION=nyears
./xmlchange RESUBMIT=1
./xmlchange DEBUG=FALSE

./xmlchange RUN_STARTDATE=0001-01-01
./xmlchange CLM_ACCELERATED_SPINUP=on
./xmlchange CCSM_CO2_PPMV=287.
./xmlchange DATM_YR_START=1901
./xmlchange DATM_YR_END=1920
./xmlchange DATM_PRESAERO=clim_1850

# For real runs
./xmlchange --subgroup case.run JOB_WALLCLOCK_TIME=24:00:00
./xmlchange --subgroup case.st_archive JOB_WALLCLOCK_TIME=00:30:00

# For debugging
# ./xmlchange JOB_WALLCLOCK_TIME=00:29:00
# ./xmlchange JOB_QUEUE=devel
# ./xmlchange NTASKS=128


./xmlchange RUNDIR=${CASE_NAME}/run
./xmlchange EXEROOT=${CASE_NAME}/bld


cat >>  user_nl_clm <<EOF
fates_paramfile='/cluster/home/jessica/NCSrevise/paramfiles/fates_LU_PPE_basefile.nc'
paramfile='/cluster/shared/noresm/inputdata/lnd/clm2/paramdata/ctsm60_params.200905_v25u.nc'
use_fates_sp=.false.
use_fates_nocomp=.true.
use_fates_fixed_biogeog=.true.
fates_stomatal_model='medlyn2011'
fates_radiation_model = 'twostream'
fates_leafresp_model = 'ryan1991'
use_fates_luh=.true.
use_fates_lupft=.true.
fates_harvest_mode='luhdata_area'
use_fates_potentialveg=.false.
fates_lu_transition_logic=1
fluh_timeseries='/cluster/shared/noresm/inputdata/LU_data_CMIP7/LUH2_states_transitions_management.timeseries_ne16_hist_steadystate_1850_2025-10-24_cdf5.nc'
flandusepftdat='/cluster/shared/noresm/inputdata/LU_data_CMIP7/fates_landuse_pft_map_to_surfdata_ne16np4_251024_cdf5.nc'
fates_spitfire_mode=1
hist_empty_htapes=.true.
hist_fincl1='FCO2', 'FATES_SECONDARY_AREA_ANTHRO_AP','FATES_SECONDARY_AREA_AP','FATES_PRIMARY_AREA_AP','FATES_NPP_LU','FATES_GPP_LU',
'FATES_VEGC_PF', 'FATES_VEGC_LU', 'FATES_LAI', 'FATES_GPP_PF'
EOF


#cat >> user_nl_datm <<EOF
#taxmode = "cycle", "cycle", "cycle"
#EOF

./case.setup
./case.build
./case.submit
