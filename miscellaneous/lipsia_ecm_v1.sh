## In this version, preprocessing and ecm are all performed in lipsia - 13.12.2013

# Step 1: convert dicom data to .v format
# Note that the '-rf dcm' parameter is only necessary if the dicom files have no suffix.
vvinidi -in /scr/dicom/data/2 -out data.v -rf dcm

# Step 2: view the data and check for image artefacts such as subject motion and in particular, check the dynamic range. If values are within a small range (less than 300 or so), it may be advisable to apply a scaling by a constant factor:

vqview -in data.v
vnormvals -in data.v -scale 10 -out data1.v # scale the data if necessary

# Step 3: correction for slice timing. This is necessary as slices are not acquired simultaneously so that their temporal offset distort results. Note however, that this step should only be performed if the repetition time is not too long (about 3 seconds or less).

vslicetime -in data1.v -out data2.v

# Step 4: correction for head motion. The text file "list.txt" contains information about translation and rotation parameters describing the motion. This file may later be used as a covariate in statistical tests. It can also be used to check for excessive motion leading to exclusion of the data set.
The next step will be a registration of the functional data to the MNI brain. Here we distinguish between two approaches. 

vmovcorrection -in data2.v -out data3.v -report list.txt

# Step 5: Registration using an anatomical scan. Using the anatomical scan to find a transformation which aligns the anatomical data to the MNI brain and then apply this transform to our functional data.

vnormdata -ana anatomical -fun data3.v -out data4.v # use the default lips MNI brain

vnormdata -ana anatomical -fun data3.v -out data4.v -ref your_reference_image.v # use the study-specific template

# Step 6: ecm calculation (bandpass filtering and ecm calculation)
vpreprocess -in swuaData.v -out fswuaData.v -low low_cutoff -high high_cutoff
vecm -in fswuaData.v -out ecm.v -mask mask.v -type selection

# Step 7: visualize the results from ecm
# If you want to visualize the ECM results, you can use the anatomical image which you used for image registration. If you dont have an anatomical image, a possible dirty "workaround" would be:
vconvert -in ecm.v -out ecm_ubyte.v -repn ubyte
vlv -in ecm_ubyte.v -z ecm.v

# Step 8: spatial smoothing with 6 mm FWHM Gaussian kernel (perform with SPM function) 


