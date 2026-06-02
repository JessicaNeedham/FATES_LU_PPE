###
### Load latest API parameter file and generate one at a time parameter files
### based on min max values from a csv file
###
import xarray as xr
import os
import sys
import csv
import pandas as pd
import shutil
import json

# Load a csv file with min max values for each parameter                                                                                            
param_ranges_full = pd.read_csv('LU_PPE_OAAT.csv')

n_params = len(param_ranges_full)
n_unique_params = len(param_ranges_full['Parameter'].unique())
param_names = param_ranges_full['Parameter'].unique()


# Load latest API parameter file                                                                                                                    
input_fname = 'fates_params_noresm_luppe.json'


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

    fout_min = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT_json/fates_params_LU_PPE_' + param_names[i] + '_min.json'
    fout_max = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT_json/fates_params_LU_PPE_' + param_names[i] + '_max.json'

    shutil.copy(input_fname, fout_min)
    shutil.copy(input_fname, fout_max)

    # get rows of the full dataframe that have that parameter                                                                                        
    tmp_df = param_ranges_full[param_ranges_full['Parameter'] == param]

    # if this is a PFT parameter loop through PFTs and modify each one                                                                              
    if(tmp_df['Dimension'].iloc[0] == 'pft'):
        for j in range(len(tmp_df)):
            minval = tmp_df['Min'].iloc[j]
            maxval = tmp_df['Max'].iloc[j]
            pft = (tmp_df['PFT_index'].iloc[j]) -1 # subtract 1 to get the correct index for the json file since PFTs are 1 indexed in the csv but 0 indexed in the json file

            print(param)
            print(minval)
            print(maxval)

            with open(fout_min, 'r') as file:
                data = json.load(file)
            data['parameters'][param]['data'][pft] = minval
            with open(fout_min, 'w') as file:
                json.dump(data, file, indent=4)    

            with open(fout_max, 'r') as file:
                data = json.load(file)
            data['parameters'][param]['data'][pft] = maxval
            with open(fout_max, 'w') as file:
                json.dump(data, file, indent=4)

    if(tmp_df['Dimension'].iloc[0] == 'lu_class'):
        for j in range(len(tmp_df)):
            minval = tmp_df['Min'].iloc[j]
            maxval = tmp_df['Max'].iloc[j]
            landuse = (tmp_df['Landuse_class_index'].iloc[j])-1
            landuse = int(landuse)

            print(param)
            print(minval)
            print(maxval)

            with open(fout_min, 'r') as file:
                data = json.load(file)
            data['parameters'][param]['data'][landuse] = minval
            with open(fout_min, 'w') as file:
                json.dump(data, file, indent=4)    

            with open(fout_max, 'r') as file:
                data = json.load(file)
            data['parameters'][param]['data'][landuse] = maxval
            with open(fout_max, 'w') as file:
                json.dump(data, file, indent=4)

    if(tmp_df['Dimension'].iloc[0] == 'global'):
        minval = tmp_df['Min'].iloc[0]
        maxval = tmp_df['Max'].iloc[0]
        dim_index=0

        print(param)
        print(dim_index)
        print(minval)
        print(maxval)            

        with open(fout_min, 'r') as file:
            data = json.load(file)
        data['parameters'][param]['data'] = minval
        with open(fout_min, 'w') as file:
            json.dump(data, file, indent=4)    

        with open(fout_max, 'r') as file:
            data = json.load(file)
        data['parameters'][param]['data'] = maxval
        with open(fout_max, 'w') as file:
            json.dump(data, file, indent=4)  




### now deal with the coordinated parameters
for i in range(0,n_unique_params):
        param = param_names[i]
        
        # skip the parameters we have already dealt with 
        if(param not in ['fates_landuse_logging_dbhmax', 'fates_landuse_logging_dbhmin', 'fates_landuse_logging_collateral_frac', 'fates_landuse_logging_coll_under_frac','fates_landuse_logging_mechanical_frac', 'fates_landuse_logging_dbhmax_infra']): 
                continue    
    
        ### Logging min and max dbh values
        param1 = 'fates_landuse_logging_dbhmax'
        tmp_df = param_ranges_full[param_ranges_full['Parameter'] == param1]
        dbhmax_minval = tmp_df['Min'].iloc[0]
        dbhmax_maxval = tmp_df['Max'].iloc[0]

        param2 = 'fates_landuse_logging_dbhmin'
        tmp_df = param_ranges_full[param_ranges_full['Parameter'] == param2]
        dbhmin_minval = tmp_df['Min'].iloc[0]
        dbhmin_maxval = tmp_df['Max'].iloc[0]

        fout_min = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT_json/fates_params_LU_PPE_fates_landuse_logging_dbh_min.json'
        fout_max = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT_json/fates_params_LU_PPE_fates_landuse_logging_dbh_max.json'

        shutil.copy(input_fname, fout_min)
        shutil.copy(input_fname, fout_max)

        with open(fout_min, 'r') as file:
            data = json.load(file)
        data['parameters'][param1]['data'] = dbhmax_minval
        data['parameters'][param2]['data'] = dbhmin_minval
        with open(fout_min, 'w') as file:
            json.dump(data, file, indent=4)

        with open(fout_max, 'r') as file:
            data = json.load(file)
        data['parameters'][param1]['data'] = dbhmax_maxval
        data['parameters'][param2]['data'] = dbhmin_maxval
        with open(fout_max, 'w') as file:
            json.dump(data, file, indent=4)

        ### Collateral damage from logging 
        param1 = 'fates_landuse_logging_collateral_frac'
        tmp_df = param_ranges_full[param_ranges_full['Parameter'] == param1]
        collateral_frac_minval = tmp_df['Min'].iloc[0]
        collateral_frac_maxval = tmp_df['Max'].iloc[0]

        param2 = 'fates_landuse_logging_coll_under_frac'
        tmp_df = param_ranges_full[param_ranges_full['Parameter'] == param2]
        coll_under_frac_minval = tmp_df['Min'].iloc[0]
        coll_under_frac_maxval = tmp_df['Max'].iloc[0]

        fout_min = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT_json/fates_params_LU_PPE_fates_landuse_logging_collateral_min.json'
        fout_max = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT_json/fates_params_LU_PPE_fates_landuse_logging_collateral_max.json'

        shutil.copy(input_fname, fout_min)
        shutil.copy(input_fname, fout_max)

         # we also have to reduce direct frac for these to work 

        with open(fout_min, 'r') as file:
            data = json.load(file)
        data['parameters'][param1]['data'] = collateral_frac_minval
        data['parameters'][param2]['data'] = coll_under_frac_minval
        data['parameters']['fates_landuse_logging_direct_frac']['data'] = 0.7
        with open(fout_min, 'w') as file:
            json.dump(data, file, indent=4)

        with open(fout_max, 'r') as file:
            data = json.load(file)
        data['parameters'][param1]['data'] = collateral_frac_maxval
        data['parameters'][param2]['data'] = coll_under_frac_maxval
        data['parameters']['fates_landuse_logging_direct_frac']['data'] = 0.7
        with open(fout_max, 'w') as file:
            json.dump(data, file, indent=4)


        # Mechanical damage from logging
        param1 = 'fates_landuse_logging_mechanical_frac'
        tmp_df = param_ranges_full[param_ranges_full['Parameter'] == param1]
        mech_frac_minval = tmp_df['Min'].iloc[0]
        mech_frac_maxval = tmp_df['Max'].iloc[0]

        param2 = 'fates_landuse_logging_dbhmax_infra'
        tmp_df = param_ranges_full[param_ranges_full['Parameter'] == param2]
        dbhmax_infra_minval = tmp_df['Min'].iloc[0]
        dbhmax_infra_maxval = tmp_df['Max'].iloc[0]

        fout_min = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT_json/fates_params_LU_PPE_fates_landuse_logging_mechanical_min.json'
        fout_max = '/cluster/home/jessica/NCSrevise/paramfiles/OAAT_json/fates_params_LU_PPE_fates_landuse_logging_mechanical_max.json'

        shutil.copy(input_fname, fout_min)
        shutil.copy(input_fname, fout_max)

        with open(fout_min, 'r') as file:
            data = json.load(file)
        data['parameters'][param1]['data'] = mech_frac_minval
        data['parameters'][param2]['data'] = dbhmax_infra_minval
        data['parameters']['fates_landuse_logging_direct_frac']['data'] = 0.7
        with open(fout_min, 'w') as file:
            json.dump(data, file, indent=4)

        with open(fout_max, 'r') as file:
            data = json.load(file)
        data['parameters'][param1]['data'] = mech_frac_maxval
        data['parameters'][param2]['data'] = dbhmax_infra_maxval
        data['parameters']['fates_landuse_logging_direct_frac']['data'] = 0.7
        with open(fout_max, 'w') as file:
            json.dump(data, file, indent=4)
