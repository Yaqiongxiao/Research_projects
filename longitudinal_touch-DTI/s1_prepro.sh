# DTI preprocessing based on FSL, adapted from Rui's script

for id in BH2K BI1K EJ1K GE2K GL5K HJ9K HN2K HP2K JT1K KE2K KL1K KL4K KS5K LH2K ML5K NL2K PH1K PL3K PT2K RB4K RC1K RL6K RN4K RT1K SB2K SC3K SE8K SM8K SN4K SP3K TJ1K TL4K UE1K UV1K VA1K VJ1K WF1K WF2K WM3K WM4K ZP1K 

do

echo "====="
echo "Topup" #for EPI distortion correction
echo "====="

#echo " - extracting first volume from AP dataset"
fslroi ${id}/AP_NIFTI/ep2d_diff_wip_monoplus_AP_1_9iso.nii.gz ${id}/ep2d_AP_B0 0 1
fslroi ${id}/PA_NIFTI/ep2d_diff_wip_monoplus_PA_1_9iso.nii.gz ${id}/ep2d_PA_B0 0 1

echo " - merging AP and PA B0 images"
# emrge the AP and PA images into a single image 
# fslmerge -t  ${id}/ep2d_APPA_B0 ${id}/AP_NIFTI/ep2d_AP_B0.nii.gz ${id}/AP_NIFTI/ep2d_diff_wip_monoplus_PA_1_9iso.nii.gz 

fslmerge -t  ${id}/ep2d_APPA_B0 ${id}/ep2d_PA_B0.nii.gz  ${id}/ep2d_AP_B0.nii.gz 


#echo " - creating file with acquisition parameters"
# create a text file that contains the information with the phase-encoding direction 

	# printf "0 -1 0 0.07722\n0 1 0 0.07722" > ${id}/acqparams_dwi.txt
	# the first three elements is a vector that specifies the direction of the phase encoding
	# -1 means AP, 1 means PA, the final column specifies the 'total readout time'
	#--> Total readout time (FSL) = (EPI factor - 1) * echo spacing = (100-1)*0.78ms=77.22 ms
	# echo spacing -> Echoabstand

echo " - executing topup"


topup --imain=${id}/ep2d_APPA_B0 --datain=acqparams_dwi.txt --config=b02b0.cnf --out=${id}/${id}_topup --fout=${id}/${id}_topup_field --iout=${id}/${id}_unwarped_B0


echo "==============="
echo "Skull stripping"
echo "==============="

echo " -creating brain mask using bet"

#fslmaths $result_dir/${subject}_unwarped -Tmean $result_dir/${subject}_unwarped_new

bet ${id}/${id}_unwarped_B0 ${id}/${id}_b0_brain -m -n -f 0.2

# -m generate binary brain mask; -f fractional intensitz threshold, default = 0.5, smaller values give larger brain outline estimates; -n don't generate segmented brain image output. 0.3 seems better than 0.2


echo "===="
echo "Eddy" #eddy current and motion correction from the output of topup
echo "===="


# create text-file index.txt, which contains a row of ones, one for each volume in ep2d_diff_wip_monoplus_AP_1_9iso.nii.gz

echo " -running eddy"

# replace ep2d_diff_wip_monoplus_AP_1_9iso with ep2d_diff_wip_monoplus_AP_clean if excluding the outliers

eddy --imain=${id}/AP_NIFTI/ep2d_diff_wip_monoplus_AP_1_9iso.nii.gz --mask=${id}/${id}_b0_brain_mask.nii.gz --acqp=acqparams_dwi.txt --index=index.txt --bvecs=${id}/AP_NIFTI/ep2d_diff_wip_monoplus_AP_1_9iso.bvec --bvals=${id}/AP_NIFTI/ep2d_diff_wip_monoplus_AP_1_9iso.bval --slm=linear --topup=${id}/${id}_topup --out=${id}/${id}_eddy_corrected

# --repol outlier replacement method is not supported with current version. RSV data looks fine

echo "========================"
echo "Compute diffusion tensor"
echo "========================"

rm -f ${subject}_dti_*

echo " - fitting the tensor"

dtifit -k ${id}/${id}_eddy_corrected -m ${id}/${id}_b0_brain_mask.nii.gz -r ${id}/${id}_eddy_corrected.eddy_rotated_bvecs -b ${id}/AP_NIFTI/ep2d_diff_wip_monoplus_AP_1_9iso.bval -o ${id}/${id}_dti

# -k, --data  dti data file; -r, --bvecs  b vectors file; -b, --bvals   b values file; -o, --out 

done 
