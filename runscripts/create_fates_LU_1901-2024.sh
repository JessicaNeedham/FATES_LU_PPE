#!/bin/bash

export COMPSET='HIST_DATM%CRUJRA2024_CLM60%FATES_SICE_SOCN_SROF_SGLC_SWAV_SESP'
export RES=f19_g17 # ne30pg3_tn14, f45_f45_mg37, ne16pg3_tn14
export MACH='betzy'
export PROJECT='nn9560k'

export USER='jessica'
export workpath='/cluster/work/users/jessica'

export TAG='noresm-fates-f19-LU-PPE-1901-2024-control'
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

./xmlchange STOP_N=31
./xmlchange STOP_OPTION=nyears
./xmlchange REST_N=31
./xmlchange REST_OPTION=nyears
./xmlchange RESUBMIT=3
./xmlchange DEBUG=FALSE

./xmlchange RUN_STARTDATE=1901-01-01
./xmlchange CLM_ACCELERATED_SPINUP=off
./xmlchange DATM_YR_START=1901
./xmlchange DATM_YR_END=2024
./xmlchange DATM_YR_ALIGN=1901
./xmlchange CLM_CO2_TYPE=diagnostic
./xmlchange DATM_CO2_TSERIES=20tr
./xmlchange CCSM_BGC=CO2A
./xmlchange DATM_PRESAERO=hist

# For real runs
./xmlchange --subgroup case.run JOB_WALLCLOCK_TIME=24:00:00
./xmlchange --subgroup case.st_archive JOB_WALLCLOCK_TIME=00:30:00

# For debugging
# ./xmlchange JOB_WALLCLOCK_TIME=00:29:00
# ./xmlchange JOB_QUEUE=devel

./xmlchange RUNDIR=${CASE_NAME}/run
#/xmlchange EXEROOT=${CASE_NAME}/bld

 ./xmlchange BUILD_COMPLETE=TRUE
 ./xmlchange EXEROOT=/cluster/work/users/jessica/ncsrevise_runs/noresm-fates-f19-LU-PPE-AD-spinup.2026-03-27/bld

 # turn on megan
 ./xmlchange CLM_BLDNML_OPTS="-bgc fates -megan"

cat >>  user_nl_clm <<EOF
do_transient_lakes=.false.
do_transient_urban=.false.
irrigate=.false.
finidat=''
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
fluh_timeseries='/cluster/work/users/jessica/trendy_lu_files_2degs/LUH2_timeseries_to_surfdata_1.9x2.5_250723_cdf5.nc'
flandusepftdat='/cluster/work/users/jessica/trendy_lu_files_2degs/fates_landuse_pft_map_to_surfdata_1.9x2.5_250723_cdf5.nc'
fates_spitfire_mode=4
hist_empty_htapes=.true.
hist_fincl1='BTRAN', 'DSTFLXT', 'EFLX_LH_TOT', 'FATES_AREA_PLANTS', 'FATES_AUTORESP', 'FATES_BURNEDAREA_LU', 'FATES_BURNFRAC',
 'FATES_DISTURBANCE_RATE_LOGGING', 'FATES_DISTURBANCE_RATE_MATRIX_LULU', 'FATES_FIRE_CLOSS', 'FATES_FRACTION', 'FATES_GPP', 
'FATES_GPP_LU', 'FATES_GRAZING', 'FATES_HET_RESP', 'FATES_LAI', 'FATES_LAI_PF', 'FATES_LEAFC', 'FATES_LITTER_AG_CWD_EL',
 'FATES_LITTER_AG_FINE_EL', 'FATES_LITTER_BG_CWD_EL', 'FATES_LITTER_BG_FINE_EL', 'FATES_LUCHANGE_WOODPROD_C_FLUX',
 'FATES_MORTALITY_CFLUX_CANOPY', 'FATES_NEP', 'FATES_NPLANT_SZ', 'FATES_NPP', 'FATES_NPP_LU', 'FATES_PATCHAREA_LU',
 'FATES_PRIMARY_AREA_AP', 'FATES_SECONDARY_AREA_ANTHRO_AP', 'FATES_SECONDARY_AREA_AP', 'FATES_TRANSITION_MATRIX_LULU', 
'FATES_VEGC', 'FATES_VEGC_ABOVEGROUND','FATES_VEGC_ABOVEGROUND_SZPF', 'FATES_VEGC_LU', 'FATES_VEGC_SZPF', 'FCO2', 'FIRE', 'FLDS', 
'FSA', 'FSDS', 'FSH', 'FSNO', 'FSR', 'H2OSNO', 'LAISUN', 'PROD100C', 'PROD10C', 'QSOIL', 'QVEGE', 'QVEGT', 'RAIN', 'SNOW',
 'TLAI', 'TOTSOILICE', 'TOTSOILLIQ', 'TOTSOMC', 'TOTSOMC_1m', 'TSA', 'TWS', 'FATES_MORTALITY_CSTARV_CFLUX_PF', 
'FATES_MORTALITY_FIRE_CFLUX_PF', 'FATES_MORTALITY_HYDRO_CFLUX_PF', 'FATES_DDBH_CANOPY_SZPF', 'FATES_DDBH_USTORY_SZPF',
'FATES_MORTALITY_CANOPY_SZPF', 'FATES_MORTALITY_USTORY_SZPF', 'FATES_MORTALITY_TERMINATION_SZPF', 'FATES_MORTALITY_IMPACT_SZPF', 
'FATES_MORTALITY_CSTARV_SZPF', 'FATES_MORTALITY_HYDRAULIC_SZPF','FATES_MORTALITY_BACKGROUND_SZPF', 'FATES_MORTALITY_SENESCENCE_SZPF', 
'FATES_MORTALITY_FREEZING_SZPF', 'FATES_NPLANT_CANOPY_SZPF','FATES_NPLANT_USTORY_SZPF',
'FATES_STOREC_SZPF', 'FATES_SAPWOODC_SZPF', 
'FATES_FROOTC_SZPF', 'FATES_REPROC_SZPF', 'FATES_LEAFC_SZPF',
'FATES_LEAF_ALLOC_SZPF', 'FATES_SEED_ALLOC_SZPF',  'FATES_FROOT_ALLOC_SZPF', 'FATES_BGSAPWOOD_ALLOC_SZPF', 
'FATES_BGSTRUCT_ALLOC_SZPF', 'FATES_AGSAPWOOD_ALLOC_SZPF', 'FATES_AGSTRUCT_ALLOC_SZPF', 'FATES_STORE_ALLOC_SZPF'
'FATES_RECRUITMENT_PF', 'FATES_NPLANT_SZPF', 'FATES_MORTALITY_LOGGING_SZPF', 'FATES_GPP_PF', 'FATES_NPP_PF',
 'FATES_GPP_SZPF', 'FATES_NPP_SZPF', 'ALT', 'ALTMAX', 'FATES_FROOTC_SL', 'FATES_MEAN_95PCTILE_HEIGHT', 'FATES_NOCOMP_PATCHAREA_PF',
  'FATES_VEGC_LUPF', 'FATES_SEED_BANK_PF', 'FATES_SEED_BANK_LUPF'
EOF

cat >> user_nl_datm_streams <<EOF
co2tseries.20tr:datafiles=/cluster/work/users/jessica/ai4pex_inputs/inputs/CO2field/fco2_datm_global_simyr_1700-2024_TRENDY_c250625.nc
co2tseries.20tr:year_last=2024
EOF

./case.setup
#/case.build
./case.submit
