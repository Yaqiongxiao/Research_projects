## In this version, preprocessing has been done in SPM (not including spatial smoothing, since it is not recommended). Bandpass filtering is performed before ecm calculation

# Step 1: convert to Lipsia
niftov -in swuaData.nii -out swuaData.v -tr repetition_time

# Step 2: create a mask for ecm analysis
# this is only an example for making a mask, masks can be created in different ways
vtimestep -in swuaData.v -out tmp.v
vbinarize -in tmp.v -out tmp_bin.v -min threshold
vlabel3d -in tmp_bin.v -out tmp_bin_label.v
vselbig -in tmp_bin_label.v -out mask.v

# Step 3: ecm analysis with temporal filtering
vpreprocess -in wuaData.v -out fwuaData.v -low low_cutoff -high high_cutoff
vecm -in fswuaData.v -out ecm.v -mask mask.v -type selection

# Step 4: convert back to NIfTI
vtonifti -in ecm.v -out ecm
fslcpgeom normheader.nii ecm0.nii

# Step 5: spatial smoothing with 6 mm FWHM Gaussian kernel (perform with SPM function) 

### batch version

subj="BH2K BI1K BJ5K BK2K EJ1K GE2K GL5K GP1K HJ9K HN2K HP2K JT1K KE2K KE5K KL1K KL4K KM5K KS5K LH2K LO1K ML5K NL2K PH1K PL3K RC1K RN4K RT1K SC3K SC4K SE8K SE9K SL4K SM8K SN4K SP3K TJ1K TL4K UE1K UV1K VA1K VJ1K WF1K WF2K WM3K WM4K ZP1K"
for id in $subj
do
3dcalc -prefix ${id}_3dcl.nii -a ${id}.nii -expr '(a+100)*100'
vvinidi -in ${id}_3dcl.nii -out ${id}.v -tr 2 # transform from .nii to .v form
vecm -in ${id}.v -mask ../mean_mask.v -out ecm_${id}.v
vvinidi -in ecm_${id}.v -out ecm_${id}.nii # transform back to .nii format
done