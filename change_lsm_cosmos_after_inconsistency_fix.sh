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
reference_dir="/home/ace/pgierz/reference_stuff/"


# Make SLM from gtc 0.5 of SLF
cdo -chname,SLF,SLM -gtc,0.5 ${expid}_SLF_after_fix.nc ${expid}_SLM_after_fix.nc

# Replace the SLF and SLM in T31GR30_jan_surf_dles_nbs.nc
cdo -replace T31GR30_jan_surf_replaced_dles_nbs.nc ${expid}_SLF_after_fix.nc tmp_T31GR30_jan_surf_replaced_dles_nbs.nc
cdo -replace tmp_T31GR30_jan_surf_replaced_dles_nbs.nc ${expid}_SLM_after_fix.nc T31GR30_jan_surf_replaced_dles_nbs_replaced.nc

# Do the cdo change_e5slm stuff on each echam5 input file
FILE_REPLACE_LIST="T31GR30_jan_surf_replaced_dles_nbs_replaced.nc T31GR30_VGRATCLIM_dles_nbs.nc T31GR30_VLTCLIM_dles_nbs.nc"
FINISHED_FILE_LIST=""
for file in $FILE_REPLACE_LIST
do
    cdo change_e5slm,${expid}_SLM_after_fix.nc "$file" "${file%.*}_after_fix.nc"
    FINISHED_FILE_LIST="${FINISHED_FILE_LIST} ${file%.*}_after_fix.nc"
done

# Modify the jsbach input file via the Veronika Gayler script:
# TODO: This would be nice to have on stan, but for now we just use ssh and rayl4:

scp $FINISHED_FILE_LIST pgierz@rayl4:/home/csys/pgierz/Research/For_Ruediger/new_jsbach/data
ssh pgierz@rayl4 'cd /home/csys/pgierz/Research/For_Ruediger/new_jsbach/; rm *nc; ./jsbach_init_file_pgierz_after_fix.ksh'
scp pgierz@rayl4:/home/csys/pgierz/Research/For_Ruediger/new_jsbach/jsbach_T31_GR30_8tiles_1992.nc jsbach_T31_GR30_8tiles_dles_nbs_after_fix.nc

cp ${FINISHED_FILE_LIST} /ace/user/pgierz/cosmos-aso-wiso/${expid}/input/echam5
cp jsbach_T31_GR30_8tiles_dles_nbs_after_fix.nc /ace/user/pgierz/cosmos-aso-wiso/${expid}/input/jsbach

cp ${expid}.run.after_fix /ace/user/pgierz/cosmos-aso-wiso/${expid}/scripts/${expid}.run
cd /ace/user/pgierz/cosmos-aso-wiso/${expid}/scripts
qsub ${expid}.run
cd -

# Clean up:
rm -v tmp_*

# Print a message about atmout inconsistency and what to do next
echo "Fingers crossed..."
