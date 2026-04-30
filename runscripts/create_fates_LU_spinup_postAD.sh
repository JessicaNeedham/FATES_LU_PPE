#!/bin/bash

export COMPSET='1850_DATM%CRUJRA2024_CLM60%FATES_SICE_SOCN_SROF_SGLC_SWAV_SESP'
export RES=ne16pg3_tn14
export MACH='betzy'
export PROJECT='nn9560k'

export USER='jessica'
export workpath='/cluster/work/users/jessica'

export TAG='noresm-fates-ne16_LU-PPE-postAD-spinup'
export CASEROOT=$workpath/ncsrevise_runs
export CIMEROOT=$workpath/noresm-def/CTSM/cime/scripts

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

# For the real thing make this 200 years (100 years with one resubmit)
./xmlchange STOP_N=25
./xmlchange STOP_OPTION=nyears
./xmlchange REST_N=25
./xmlchange REST_OPTION=nyears
./xmlchange RESUBMIT=3
./xmlchange DEBUG=FALSE

./xmlchange RUN_STARTDATE=0401-01-01 # check this matches end of AD spinup run
./xmlchange CLM_ACCELERATED_SPINUP=off
./xmlchange CCSM_CO2_PPMV=287.
./xmlchange DATM_YR_START=1901
./xmlchange DATM_YR_END=1920
./xmlchange DATM_PRESAERO=clim_1850

# turn on megan for NCSrevise runs
./xmlchange CLM_BLDNML_OPTS="-bgc fates -megan"

# For real runs
./xmlchange --subgroup case.run JOB_WALLCLOCK_TIME=24:00:00
./xmlchange --subgroup case.st_archive JOB_WALLCLOCK_TIME=00:30:00

# For debugging
# ./xmlchange JOB_WALLCLOCK_TIME=00:29:00
# ./xmlchange JOB_QUEUE=devel
# ./xmlchange NTASKS=128

./xmlchange RUNDIR=${CASE_NAME}/run
#./xmlchange EXEROOT=${CASE_NAME}/bld

# use existing build
./xmlchange BUILD_COMPLETE=TRUE
./xmlchange EXEROOT=/cluster/work/users/jessica/ncsrevise_runs/noresm-fates-ne16-LU-PPE-AD-spinup.2026-04-24/bld

cat >>  user_nl_clm <<EOF
finidat='/cluster/work/users/jessica/ncsrevise_runs/noresm-fates-ne16-LU-PPE-AD-spinup.2026-04-24/run/noresm-fates-ne16-LU-PPE-AD-spinup.2026-04-24.clm2.r.0401-01-01-00000.nc'
fates_paramfile='/cluster/home/jessica/NCSrevise/paramfiles/fates_params_pr52.nc'
use_fates_sp=.false.
use_fates_nocomp=.true.
use_fates_fixed_biogeog=.true.
use_fates_luh=.true.
use_fates_lupft=.true.
fates_harvest_mode='luhdata_area'
use_fates_potentialveg=.false.
fluh_timeseries='/cluster/shared/noresm/inputdata/LU_data_CMIP7/LUH2_states_transitions_management.timeseries_ne16_hist_steadystate_1850_2025-11-06_cdf5.nc'
flandusepftdat='/cluster/shared/noresm/inputdata/LU_data_CMIP7/fates_landuse_pft_map_to_surfdata_ne16np4_251106_cdf5.nc'
fates_spitfire_mode=4
hist_empty_htapes=.true.
hist_fincl1='FCO2', 'FATES_GPP_LU', 
'FATES_VEGC_LU', 'FATES_PATCHAREA_LU', 'FATES_NPP_LU', 'FATES_LUCHANGE_WOODPROD_C_FLUX', 'FATES_DISTURBANCE_RATE_LOGGING',
'FATES_VEGC_ABOVEGROUND', 'FATES_VEGC', 'FATES_FRACTION', 'FATES_GPP','FATES_NEP','FATES_AUTORESP', 'FATES_HET_RESP', 'QVEGE',
 'QVEGT','QSOIL','EFLX_LH_TOT','FSH','FSR', 'FSDS','FSA','FIRE','FLDS','FATES_LAI', 'FATES_VEGC_PF'
EOF

./case.setup
#./case.build
./case.submit
