# change_lsm_cosmos

## Procedure from bash history:
```bash
mkdir old_ncfiles
ls *nc
mv *nc old_ncfiles/
ls
cdo -f nc -sellevel,6 -selvar,3 LIG130_dles_nbs_mpiom_08000101_08000131.grb lsm_mpiomgrid.nc
cdo -f nc -sellevel,6 -selcode,3 LIG130_dles_nbs_mpiom_08000101_08000131.grb lsm_mpiomgrid.nc
ncview lsm_mpiomgrid.nc 
cdo -setmisstoc,1 -setrtoc,-100,100,0 lsm_mpiomgrid.nc lsm_mpiomgrid_binary_mask.nc
ncview lsm_mpiomgrid_binary_mask.nc 
cdo -f nc -remapcon,t31grid -setgrid,/home/ace/pgierz/reference_stuff/GR30s.nc -selindexbox,2,101,1,101 -setgrid,r122x101 lsm_mpiomgrid_binary_mask.nc lsm_t31grid_fractional_mask.nc
ncview lsm_t31grid_fractional_mask.nc 
cdo -f nc -remapcon,t31grid -setgrid,/home/ace/pgierz/reference_stuff/GR30s.nc -selindexbox,2,121,1,101 -setgrid,r122x101 lsm_mpiomgrid_binary_mask.nc lsm_t31grid_fractional_mask.nc
ncview lsm_t31grid_fractional_mask.nc 
cdo setmisstoc,1 lsm_t31grid_fractional_mask.nc lsm_t31grid_fractional_mask_miss1.nc
ncview lsm_t31grid_fractional_mask_miss1.nc 
cdo -chname,var3,SLF lsm_t31grid_fractional_mask_miss1.nc lsm_SLF.nc
ls
cdo -chname,SLF,SLM -gtc,0.5 lsm_SLF.nc lsm_SLM.nc
ncview lsm_SLM.nc 
cp ~/reference_stuff/T31GR30_jan_surf.nc .
ls
cdo -h replace
cdo replace T31GR30_jan_surf.nc lsm_SLF.nc one.nc
cdo replace one.nc lsm_SLM.nc final.nc
ncview final.nc 
history
ncview lsm_SLF.nc 
ls
ncview final.nc 
ls
ncdump -h lsm_SLF.nc 
ncwa -a time lsm_SLF.nc test.nc
ncdump -h test.nc 
ncwa -a time,lev lsm_SLF.nc test.nc
ncdump -h test.nc 
ls
mv test.nc lsm_SLF.nc
ncwa -a time,lev lsm_SLM.nc test.nc
mv test.nc lsm_SLM.nc
ls
cdo replace T31GR30_jan_surf.nc lsm_SLF.nc one.nc
cdo replace one.nc lsm_SLM.nc final.nc
ncview final.nc 
cdo change_e5slm,lsm_SLM.nc final.nc final_new.nc
ncview final_new.nc 
```
