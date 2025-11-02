###
### Load latest API parameter file and generate one at a time parameter files
### based on min max values from a csv file
###

# Load libraries needed to manipulate netcdf files
import xarray as xr
import os
import sys  
import netCDF4 as nc4 
import csv
import pandas as pd 
import shutil

import modp as mp


# Load a csv file with min max values for each parameter
param_ranges_full = pd.read_csv('LU_PPE_OAAT.csv')

n_params = len(param_ranges_full)
n_unique_params = len(param_ranges_full['Parameter'].unique())
param_names = param_ranges_full['Parameter'].unique()

# Load latest API parameter file
input_fname = 'fates_params_default.nc'

# For each parameter loop through and create a new parameter file with only that parameter changed - min and max
# If it is a PFT parameter change all PFTs together
# If it is a land use class parameter change all land use classes together
# Save each parameter file with a name that indicates the parameter and whether it is min or max
for i in range(0,n_unique_params):

    param = param_names[i]

    # skip the more complicated parameters that need to be coordinated with other parameters
    if(param in ['fates_landuse_logging_dbhmax', 'fates_landuse_logging_dbhmin', 
                 'fates_landuse_logging_collateral_frac', 'fates_landuse_logging_coll_under_frac', 
                 'fates_landuse_logging_mechanical_frac', 'fates_landuse_logging_dbhmax_infra']): 
        continue 
    
    fout_min = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT/fates_params_LU_PPE_' + param_names[i] + '_min.nc'
    fout_max = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT/fates_params_LU_PPE_' + param_names[i] + '_max.nc'

    shutil.copy(input_fname, fout_min)
    shutil.copy(input_fname, fout_max)

    # get rows of the full dataframe that have that parameter
    tmp_df = param_ranges_full[param_ranges_full['Parameter'] == param]


    # if this is a PFT parameter loop through PFTs and modify each one 
    if(tmp_df['Dimension'].iloc[0] == 'pft'):
        for j in range(len(tmp_df)):
            minval = tmp_df['Min'].iloc[j]
            maxval = tmp_df['Max'].iloc[j]
            pft = tmp_df['PFT_index'].iloc[j]
            organ = float('nan')

            print(param)
            print(minval)
            print(maxval)

            mp.main(var = param, dim_index = pft, fin = fout_min, val = minval, 
                    fout = fout_min, O = 1, organ = organ)

            mp.main(var = param, dim_index = pft, fin = fout_max, val = maxval, 
                    fout = fout_max, O = 1, organ = organ)
        
    if(tmp_df['Dimension'].iloc[0] == 'lu_class'):
        for j in range(len(tmp_df)):
            minval = tmp_df['Min'].iloc[j]
            maxval = tmp_df['Max'].iloc[j]
            landuse = tmp_df['Landuse_class_index'].iloc[j]
            organ = float('nan')

            print(param)
            print(minval)
            print(maxval)


            mp.main(var = param, dim_index = landuse, fin = fout_min, val = minval, 
                    fout = fout_min, O = 1, organ = organ)

            mp.main(var = param, dim_index = landuse, fin = fout_max, val = maxval, 
                    fout = fout_max, O = 1, organ = organ)


    if(tmp_df['Dimension'].iloc[0] == 'global'):  
        minval = tmp_df['Min'].iloc[0]
        maxval = tmp_df['Max'].iloc[0]
        organ = float('nan')
        dim_index=0

        print(param)
        print(dim_index)
        print(minval)
        print(maxval)


        mp.main(var = param, dim_index = dim_index, fin = fout_min, val = minval, 
                fout = fout_min, O = 1, organ = organ)

        mp.main(var = param, dim_index = dim_index, fin = fout_max, val = maxval, 
                fout = fout_max, O = 1, organ = organ)          
        



        ##### Now deal with the coordinated parameters #####

        ### Logging min and max dbh values
        param1 = 'fates_landuse_logging_dbhmax'
        tmp_df = param_ranges_full[param_ranges_full['Parameter'] == param1]
        dbhmax_minval = tmp_df['Min'].iloc[0]
        dbhmax_maxval = tmp_df['Max'].iloc[0]

        param2 = 'fates_landuse_logging_dbhmin'
        tmp_df = param_ranges_full[param_ranges_full['Parameter'] == param2]
        dbhmin_minval = tmp_df['Min'].iloc[0]
        dbhmin_maxval = tmp_df['Max'].iloc[0]

        fout_min = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT/fates_params_LU_PPE_fates_landuse_logging_dbh_min.nc'
        fout_max = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT/fates_params_LU_PPE_fates_landuse_logging_dbh_max.nc'

        shutil.copy(input_fname, fout_min)
        shutil.copy(input_fname, fout_max)

        mp.main(var = param1, dim_index = 0, fin = fout_min, val = dbhmax_minval, 
                fout = fout_min, O = 1, organ = organ)

        mp.main(var = param1, dim_index = 0, fin = fout_max, val = dbhmax_maxval, 
                fout = fout_max, O = 1, organ = organ)
        
        mp.main(var = param2, dim_index = 0, fin = fout_min, val = dbhmin_minval, 
                fout = fout_min, O = 1, organ = organ)

        mp.main(var = param2, dim_index = 0, fin = fout_max, val = dbhmin_maxval, 
                fout = fout_max, O = 1, organ = organ)
        
        ### Collateral damage from logging 
        param1 = 'fates_landuse_logging_collateral_frac'
        tmp_df = param_ranges_full[param_ranges_full['Parameter'] == param1]
        collateral_frac_minval = tmp_df['Min'].iloc[0]
        collateral_frac_maxval = tmp_df['Max'].iloc[0]

        param2 = 'fates_landuse_logging_coll_under_frac'
        tmp_df = param_ranges_full[param_ranges_full['Parameter'] == param2]
        coll_under_frac_minval = tmp_df['Min'].iloc[0]
        coll_under_frac_maxval = tmp_df['Max'].iloc[0]

        fout_min = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT/fates_params_LU_PPE_fates_landuse_logging_collateral_min.nc'
        fout_max = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT/fates_params_LU_PPE_fates_landuse_logging_collateral_max.nc'

        shutil.copy(input_fname, fout_min)
        shutil.copy(input_fname, fout_max)

        mp.main(var = param1, dim_index = 0, fin = fout_min, val = collateral_frac_minval, 
                fout = fout_min, O = 1, organ = organ)

        mp.main(var = param1, dim_index = 0, fin = fout_max, val = collateral_frac_maxval, 
                fout = fout_max, O = 1, organ = organ)
        
        mp.main(var = param2, dim_index = 0, fin = fout_min, val = coll_under_frac_minval, 
                fout = fout_min, O = 1, organ = organ)

        mp.main(var = param2, dim_index = 0, fin = fout_max, val = coll_under_frac_maxval, 
                fout = fout_max, O = 1, organ = organ)
        
        # we also have to reduce direct frac for these to work 
        mp.main(var = 'fates_landuse_logging_direct_frac', dim_index = 0, fin = fout_min, val = 0.7, 
                fout = fout_min, O = 1, organ = organ)

        mp.main(var = 'fates_landuse_logging_direct_frac', dim_index = 0, fin = fout_max, val = 0.7, 
                fout = fout_max, O = 1, organ = organ)
        

        # Mechanical damage from logging
        param1 = 'fates_landuse_logging_mechanical_frac'
        tmp_df = param_ranges_full[param_ranges_full['Parameter'] == param1]
        mech_frac_minval = tmp_df['Min'].iloc[0]
        mech_frac_maxval = tmp_df['Max'].iloc[0]

        param2 = 'fates_landuse_logging_dbhmax_infra'
        tmp_df = param_ranges_full[param_ranges_full['Parameter'] == param2]
        dbhmax_infra_minval = tmp_df['Min'].iloc[0]
        dbhmax_infra_maxval = tmp_df['Max'].iloc[0]

        fout_min = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT/fates_params_LU_PPE_fates_landuse_logging_mechanical_min.nc'
        fout_max = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT/fates_params_LU_PPE_fates_landuse_logging_mechanical_max.nc'

        shutil.copy(input_fname, fout_min)
        shutil.copy(input_fname, fout_max)

        mp.main(var = param1, dim_index = 0, fin = fout_min, val = mech_frac_minval, 
                fout = fout_min, O = 1, organ = organ)

        mp.main(var = param1, dim_index = 0, fin = fout_max, val = mech_frac_maxval, 
                fout = fout_max, O = 1, organ = organ)

        mp.main(var = param2, dim_index = 0, fin = fout_min, val = dbhmax_infra_minval, 
                fout = fout_min, O = 1, organ = organ)

        mp.main(var = param2, dim_index = 0, fin = fout_max, val = dbhmax_infra_maxval, 
                fout = fout_max, O = 1, organ = organ)
        
        # we also have to reduce direct frac for these to work 
        mp.main(var = 'fates_landuse_logging_direct_frac', dim_index = 0, fin = fout_min, val = 0.7, 
                fout = fout_min, O = 1, organ = organ)

        mp.main(var = 'fates_landuse_logging_direct_frac', dim_index = 0, fin = fout_max, val = 0.7, 
                fout = fout_max, O = 1, organ = organ)
