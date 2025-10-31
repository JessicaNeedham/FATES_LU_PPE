#!/bin/bash

# change directory to where each case is
cd /cluster/work/users/jessica/ncsrevise_runs/OAAT


# go into each case and update run settings
for dir in */; do
    
    # change into each case
    cd "$dir" || continue

    echo "Restarting case $dir"

    ./xmlchange STOP_N=62
    ./xmlchange STOP_OPTION=nyears
    ./xmlchange REST_N=31
    ./xmlchange REST_OPTION=nyears
    ./xmlchange RESUBMIT=1
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


    # resubmit the run
    ./xmlchange CONTINUE_RUN=TRUE
    # return to parent directory
    cd ..
done


