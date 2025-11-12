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
    ./xmlchange DATM_YR_START=1901
    ./xmlchange DATM_YR_END=2023
    ./xmlchange DATM_YR_ALIGN=1901


    # resubmit the run
    ./xmlchange CONTINUE_RUN=TRUE
    ./case.submit
    # return to parent directory
    cd ..
done


