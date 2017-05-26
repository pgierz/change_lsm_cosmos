#!/bin/bash -e
################################################################################
# Paul Gierz, May 2017
#
# This script performs all necessary steps for changing the land sea mask in a cosmos simulation.
#
# The following is presumed:
#     * A changed topojj file
#     * A cosmos-o simulation using this file
#
################################################################################
expid=LIG130_dles_nbs
path_cosmos_o="/ace/user/pgierz/cosmos-o/${expid}/outdata/mpiom/"
reference_dir="/home/ace/user/pgierz/reference_stuff/"


# make a binary land sea mask from mpiom code 3 top level
cdo -f nc -setmisstoc,1 \
    -setrtoc,-100,100,0 \
    -sellevel,6 \
    -selcode,3 \
    ${path_cosmos_o}/${expid}_mpiom_08000101_08000131.grb \
    tmp_lsm_mpiomgrid.nc

# Remap to a T31 grid and set missing values to 1 (land)
cdo -setmisstoc,1 \
    -remapcon,t31grid \
    -setgrid,${reference_dir}/GR30s.nc \
    -selindexbox,2,121,1,101 \
    -setgrid,r122x101 \
    tmp_lsm_mpiomgrid.nc \
    tmp_lsm_t31_grid.nc

# Rename to SLF
cdo -chname,var3,SLF tmp_lsm_t31_grid.nc ${expid}_SLF.nc

# Make SLM from gtc 0.5 of SLF
cdo -chname,SLF,SLM -gtc,0.5 tmp_${expid}_SLF.nc ${expid}_SLM.nc

# remove time and level from SLF and SLM files
nncwa -a time,lev ${expid}_SLF.nc tmp
mv tmp ${expid}_SLF.nc

cwa -a time,lev ${expid}_SLM.nc tmp
mv tmp ${expid}_SLM.nc

# Get echam5 input files
cp ${reference_dir}/T31GR30_jan_surf.nc .
# FIXME: The next two lines are wrong, we need the real filenames
cp ${reference_dir}/T31GR30_VRATCLIM .
cp ${reference_dir}/T31GR30_VEGCLIM .

# Do the cdo change_e5slm stuff on each echam5 input file
FILE_REPLACE_LIST="T31GR30_jan_surf.nc T31GR30_VRATCLIM.nc T31GR30_VEGCLIM.nc"
FINISHED_FILE_LIST=""
for file in $FILE_REPLACE_LIST
do
    cdo change,e5slm,${expid}_SLM.nc "$file" "${file%.*}_dles_nbs.nc"
    FINISHED_FILE_LIST="${FINISHED_FILE_LIST} ${file%.*}_dles_nbs.nc"
done

# Modify the jsbach input file via the Veronika Gayler script:
echo "Now you need to copy the files in ${FINISHED_FILE_LIST}"
echo "to rayl4 and run init_jsbach.ksh"

# Clean up:
rm -v tmp_*
