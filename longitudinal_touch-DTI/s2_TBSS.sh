#!/bin/bash

# TBSS  http://fsl.fmrib.ox.ac.uk/fslcourse/lectures/practicals/fdt1/
# https://web.stanford.edu/group/vista/cgi-bin/wiki/index.php/MrVista_TBSS

## check the data
# slicesdir *nii.gz  open the resulting web page report; this is a quick-and-dirty way of checking through all the original images.

# delete KE2K  because of head motion

##preprocessing

for id in BH2K BI1K EJ1K GE2K GL5K HJ9K HN2K HP2K JT1K KL1K KL4K KE2K KS5K LH2K ML5K NL2K PH1K PL3K PT2K RB4K RC1K RL6K RT1K SB2K SC3K SE8K SM8K SN4K SP3K TJ1K TL4K UE1K UV1K VA1K VJ1K WF1K WF2K WM3K WM4K ZP1K 

do
# step 1: preparing FA data for TBSS (copy all FA to a new folder TBSS)
tbss_1_preproc ${id}_dti_FA.nii.gz 

# step 2: registering all the FA data
tbss_2_reg -T FMRIB58_FA_1mm origdata/${id}_dti_FA.nii.gz

done

# step 3: post-registration processing
tbss_3_postreg -S

# check the mean FA images
# cd stats
#fsleyes /a/software/fsl/5.0.9/ubuntu-xenial-amd64/data/MNI152_T1_1mm mean_FA -cm red-yellow -dr 0.2 0.6  

# step 4: projecting all pre-aligned FA data onto the skeleton
# thresholds the mean FA skeleton image and finds the skeleton in each individual subject. 
tbss_4_prestats 0.2  #binary skeleton mask that defines the set of voxels used in all subsequent processing, try 0.2 and 0.3

# statistical processing in FSL
cd stats
#randomise -i all_FA_skeletonised.nii.gz -o FA_touch -d ../DWI_37.mat -t ../DWI_37.con -n 1000 --T2 -D

randomise -i all_FA_skeletonised.nii.gz -o FA_touch -d ../../DWI_40.mat -t ../../DWI_40.con -m mean_FA_skeleton_mask -n 1000 --T2 -D -x --uncorrp 

#-D demeans the FA values
#--T2 sets threshold-Free Cluster Enhancement with 2D optimisation (e.g., for TBSS data); H=2, E=1, C=26

# output: 
#   *_tstat(N).nii.gz
#   *_tfce_p_tstat (and possibly faMath_tfce_p_fstat)
#   *_tfce_corrp_tstat (and possibly faMath_tfce_corrp_fstat) 