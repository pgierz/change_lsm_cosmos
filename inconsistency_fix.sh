#!/bin/bash
expid=LIG130_dles_nbs
path_cosmos_aso="/ace/user/pgierz/cosmos-aso-wiso/${expid}"

# Get the atmout file from work
cp ${path_cosmos_aso}/work/atmout atmout_test

# Get the SLF from the already adjusted file
cdo -selvar,SLF T31GR30_jan_surf_replaced_dles_nbs.nc tmp_T31GR30_jan_surf_SLF.nc


#####USER INTERFACE#####

#definition of the file containing the information on erroneous SLM points
#ADJUST TO YOUR NEEDS!
error_log="atmout_test"

#definition of erroneous SLM file
##ADJUST TO YOUR NEEDS!
buggy_file="tmp_T31GR30_jan_surf_SLF.nc"

#definition of filename for the corrected SLM file 
##ADJUST TO YOUR NEEDS!
corrected_file="${expid}_SLF_after_fix.nc"

#####END USER INTERFACE#####
#####NOTHING TO BE ADJUSTED AFTER THIS POINT#####




#extract relevant information from the error_log
cat $error_log | grep "WARNING !!!slf,alake,tsw:" > tmp.txt

#extract longitude and latitude information from the SLM-error log
counter=0
while read c1 c2 c3 c4 c5 c6 c7
do
counter=$(($counter+1));
lat[counter]=$c7
lon[counter]=$c6
#echo "lat: $c7; lon: $c6"
done < "tmp.txt"
max_elements=$counter

#copy erroneous SLM-file to a target file
cp $buggy_file $corrected_file

#incrementally correct the SLM using cdo setcindexbox
for ((counter=1; counter <= max_elements ; counter++))  # Double parentheses, and "LIMIT" with no "$".
do
  lat_coordinate=${lat[$counter]}
  lon_coordinate=${lon[$counter]}
  #echo "lat: $lat_coordinate; lon: $lon_coordinate"
  cdo setcindexbox,1,$lon_coordinate,$lon_coordinate,$lat_coordinate,$lat_coordinate $corrected_file tmp.nc
  mv tmp.nc $corrected_file
done        

echo "This script read in locations of $max_elements grid cells and corrected the SLM at $((counter-1)) grid cells!"

#clean up
rm tmp.txt
