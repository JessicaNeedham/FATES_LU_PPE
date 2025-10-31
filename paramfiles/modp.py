#!/usr/bin/env python

# Full script written by C. Koven, 2018
# This is a very short extract adapted by J. Needham 2021
            
        
import os
from scipy.io import netcdf as nc
import shutil
import tempfile
import numpy as np
            
            
def main(var, dim_index, fin, val, fout, O, organ):
            
    # work with the file in some random temporary place so that if something goes wrong, then nothing happens to original file and it doesn't make a persistent output file
    tempdir = tempfile.mkdtemp()
    tempfilename = os.path.join(tempdir, 'temp_fates_param_file.nc')
    ncfile_old = None
    outputfname = fout
       
    outputval = float(val)

    dim_i = int(dim_index)
   
    shutil.copyfile(fin, tempfilename)
    ncfile = nc.netcdf_file(tempfilename, 'a')                  
    var = ncfile.variables[var]
    
    ndim_file = len(var.dimensions)

    if(ndim_file==0):
        var[()] = outputval
    else:
        if dim_i == 0 : 
            var.assignValue(outputval)
        else : 
            var[dim_i-1] = outputval
           

    ncfile.close()
    if type(ncfile_old) != type(None):
        ncfile_old.close()
        #
        #
        # now move file from temporary location to final location
    if O == 1:   
        os.remove(outputfname)
    shutil.move(tempfilename, outputfname)
    shutil.rmtree(tempdir, ignore_errors=True)
            
   # =======================================================================================
   # This is the actual call to main
               
if __name__ == "__main__":
    main()