#!/bin/bash

export COMPSET='1850_DATM%CRUJRA2024_CLM60%FATES_SICE_SOCN_SROF_SGLC_SWAV_SESP'
export RES=f19_g17 #"ne16pg3_tn14"   # "f45_f45_mg37" # ne16pg3_tn14, #f19_g17, ne30pg3_tn14, f45_f45_mg37, ne16pg3_tn14
export MACH='betzy'
export PROJECT='nn9560k'

export USER='jessica'
export workpath='/cluster/work/users/jessica'

export TAG='noresm-fates-f19_LU-PPE-postAD-spinup'
export CASEROOT=$workpath/ncsrevise_runs
export CIMEROOT=$workpath/noresm-lu-pr/CTSM/cime/scripts

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
./xmlchange RESUBMIT=6
./xmlchange DEBUG=FALSE

./xmlchange RUN_STARTDATE=0276-01-01 # check this matches end of AD spinup run
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
./xmlchange EXEROOT=/cluster/work/users/jessica/ncsrevise_runs/noresm-fates-f19-LU-PPE-AD-spinup.2026-03-27/bld

cat >>  user_nl_clm <<EOF
finidat='/cluster/work/users/jessica/ncsrevise_runs/noresm-fates-f19-LU-PPE-AD-spinup.2026-03-27/run/noresm-fates-f19-LU-PPE-AD-spinup.2026-03-27.clm2.r.0276-01-01-00000.nc'
fsurdat='/cluster/shared/noresm/inputdata/lnd/clm2/surfdata_esmf/ctsm5.3.0/surfdata_1.9x2.5_hist_2000_16pfts_c240908.nc'
fates_paramfile='/cluster/home/jessica/NCSrevise/paramfiles/fates_params_LU_PPE_base_270326.nc'
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
fluh_timeseries='/cluster/work/users/jessica/trendy_lu_files_2degs/LUH2_states_transitions_management.timeseries_1.9x2.5_hist_steadystate_1700_2025-07-23_cdf5.nc'
flandusepftdat='/cluster/work/users/jessica/trendy_lu_files_2degs/fates_landuse_pft_map_to_surfdata_1.9x2.5_250723_cdf5.nc'
fates_spitfire_mode=4
hist_empty_htapes=.true.
hist_fincl1='FCO2', 'FATES_GPP_LU', 'FATES_DISTURBANCE_RATE_MATRIX_LULU', 'FATES_TRANSITION_MATRIX_LULU', 'FATES_BURNEDAREA_LU',
'FATES_VEGC_LU', 'FATES_PATCHAREA_LU', 'FATES_NPP_LU', 'FATES_LUCHANGE_WOODPROD_C_FLUX', 'FATES_DISTURBANCE_RATE_LOGGING',
'FATES_VEGC_ABOVEGROUND', 'FATES_VEGC', 'FATES_FRACTION', 'FATES_GPP','FATES_NEP','FATES_AUTORESP', 'FATES_HET_RESP', 'QVEGE',
 'QVEGT','QSOIL','EFLX_LH_TOT','FSH','FSR', 'FSDS','FSA','FIRE','FLDS','FATES_LAI', 'FATES_VEGC_PF', 
'FATES_SECONDARY_AREA_ANTHRO_AP','FATES_SECONDARY_AREA_AP','FATES_PRIMARY_AREA_AP','FATES_NPP_LU','FATES_GPP_LU'
EOF

./case.setup
#./case.build
./case.submit
