#!/bin/bash

export COMPSET='HIST_DATM%CRUJRA2024_CLM60%FATES_SICE_SOCN_SROF_SGLC_SWAV_SESP'
export RES=f19_g17  #, ne30pg3_tn14, f45_f45_mg37, ne16pg3_tn14
export MACH='betzy'
export PROJECT='nn9188k'

export USER='jessica'
export workpath='/cluster/work/users/jessica'

export TAG='noresm-fates-f19-LU-PPE-1850-1900-control'
export CASEROOT=$workpath/ncsrevise_runs
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

./xmlchange STOP_N=10
./xmlchange STOP_OPTION=nyears
./xmlchange REST_N=10
./xmlchange REST_OPTION=nyears
./xmlchange RESUBMIT=4
./xmlchange DEBUG=FALSE

./xmlchange RUN_STARTDATE=1851-01-01
./xmlchange CLM_ACCELERATED_SPINUP=off
./xmlchange DATM_YR_START=1901
./xmlchange DATM_YR_END=1920
./xmlchange DATM_YR_ALIGN=1851
./xmlchange DATM_PRESAERO=hist
./xmlchange CLM_CO2_TYPE=diagnostic
./xmlchange DATM_CO2_TSERIES=20tr
./xmlchange CCSM_BGC=CO2A


# For real runs
./xmlchange --subgroup case.run JOB_WALLCLOCK_TIME=24:00:00
./xmlchange --subgroup case.st_archive JOB_WALLCLOCK_TIME=00:30:00

# For debugging
#./xmlchange JOB_WALLCLOCK_TIME=00:29:00
#./xmlchange JOB_QUEUE=devel

./xmlchange RUNDIR=${CASE_NAME}/run
./xmlchange EXEROOT=${CASE_NAME}/bld

#./xmlchange BUILD_COMPLETE=TRUE
#./xmlchange EXEROOT=/cluster/work/users/jessica/ncsrevise_runs/noresm-fates-f19-LU-PPE-AD-spinup.2026-03-27/bld

# turn on megan
./xmlchange CLM_BLDNML_OPTS="-bgc fates -megan"

cat >> user_nl_clm <<EOF
do_transient_lakes=.false.
do_transient_urban=.false.
irrigate=.false.
finidat='/cluster/work/users/jessica/LU-PPE_files/noresm-fates-f19_LU-PPE-postAD-spinup.2026-05-20.clm2.r.0501-01-01-00000.nc'
fates_paramfile='/cluster/home/jessica/NCSrevise/paramfiles/fates_params_noresm_luppe.json'
use_fates_sp=.false.
use_fates_nocomp=.true.
use_fates_fixed_biogeog=.true.
fates_stomatal_model='medlyn2011'
fates_lu_transition_logic=1
use_fates_luh=.true.
use_fates_lupft=.true.
fates_harvest_mode='luhdata_area'
use_fates_potentialveg=.false.
fluh_timeseries='/cluster/work/users/jessica/LU-PPE_files/LUH3_timeseries_850-2024_surfdata_1.9x2.5_c260514.nc'
flandusepftdat='/cluster/work/users/jessica/LU-PPE_files/fates_landuse_pft_surfdata_1.9x2.5_c260513.nc'
fates_spitfire_mode=4
hist_fincl1=
'FATES_FRACTION', 'FATES_NOCOMP_PATCHAREA_PF', 
'FATES_AUTORESP', 'HR', 'FATES_BURNFRAC', 
'FATES_VEGC', 'FATES_VEGC_ABOVEGROUND','FATES_VEGC_SZPF', 'FATES_VEGC_ABOVEGROUND_SZPF', 'FATES_LEAFC_SZPF', 'FATES_STOREC_SZPF',
'FATES_REPROC_SZPF', 'FATES_BASALAREA_SZPF', 'FATES_NPLANT_SZPF', 'FATES_LAI_PF', 'FATES_CROWNAREA_PF', 
'Z0MG', 'FSR', 'FSDS', 'FATES_SAPWOODC_SZPF', 'FATES_FROOTC_SZPF', 'FATES_SAPWOOD_ALLOC_CANOPY_SZ' 'FATES_STRUCT_ALLOC_CANOPY_SZ', 
'FATES_SAPWOOD_ALLOC_USTORY_SZ', 'FATES_STRUCT_ALLOC_USTORY_SZ', 'FATES_MORTALITY_CFLUX_PF',
'FATES_MORTALITY_HYDRO_CFLUX_PF', 'FATES_MORTALITY_FIRE_CFLUX_PF', 'FATES_MORTALITY_BACKGROUND_CFLUX_PF','FATES_MORTALITY_SENESCENCE_CFLUX_PF',
'FATES_MORTALITY_CSTARV_CFLUX_PF',
'FATES_MORTALITY_CANOPY_SZPF', 'FATES_MORTALITY_USTORY_SZPF', 'FATES_MORTALITY_BACKGROUND_SZPF','FATES_MORTALITY_HYDRAULIC_SZPF',
'FATES_MORTALITY_CSTARV_SZPF','FATES_MORTALITY_IMPACT_SZPF','FATES_MORTALITY_WILDFIRE_SZPF','FATES_MORTALITY_TERMINATION_SZPF',
'FATES_MORTALITY_FREEZING_SZPF','FATES_MORTALITY_SENESCENCE_SZPF'
 'FATES_GPP_PF', 'FATES_NPP_PF', 'FCO2', 
'BTRAN', 'DSTFLXT', 'EFLX_LH_TOT', 'FATES_AREA_PLANTS', 'FATES_BURNEDAREA_LU',
 'FATES_DISTURBANCE_RATE_LOGGING', 'FATES_FIRE_CLOSS', 'FATES_FRACTION', 'FATES_GPP', 
'FATES_GPP_LU', 'FATES_GRAZING', 'FATES_HET_RESP', 'FATES_LEAFC', 'FATES_LUCHANGE_WOODPROD_C_FLUX',
 'FATES_MORTALITY_CFLUX_CANOPY', 'FATES_NEP', 'FATES_NPP_LU', 'FATES_PATCHAREA_LU',
 'FATES_VEGC_LU', 'FIRE', 'FLDS', 
'FSA', 'FSH', 'FSNO', 'H2OSNO', 'LAISUN', 'PROD100C', 'PROD10C', 'QSOIL', 'QVEGE', 'QVEGT', 'RAIN', 'SNOW',
 'TLAI', 'TOTSOILICE', 'TOTSOILLIQ', 'TOTSOMC', 'TOTSOMC_1m', 'TSA', 'TWS', 'FATES_DDBH_CANOPY_SZPF', 'FATES_DDBH_USTORY_SZPF',
 'FATES_NPLANT_CANOPY_SZPF','FATES_NPLANT_USTORY_SZPF',  
'FATES_RECRUITMENT_PF',  'ALTMAX'
EOF

    cat >> user_nl_datm_streams <<EOF
co2tseries.20tr:datafiles=/cluster/work/users/jessica/LU-PPE_files/fco2_datm_global_simyr_1700-2024_TRENDY_c250625.nc
co2tseries.20tr:year_last=2024
EOF

#fluh_timeseries='/cluster/work/users/jessica/trendy_lu_files_2degs/LUH2_timeseries_to_surfdata_1.9x2.5_250723_cdf5.nc'
#flandusepftdat='/cluster/work/users/jessica/trendy_lu_files_2degs/fates_landuse_pft_map_to_surfdata_1.9x2.5_250723_cdf5.nc'

./case.setup
./case.build
./case.submit
