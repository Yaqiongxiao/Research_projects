%%% vbm longitudinal analysis
cd('/NOBACKUP/xiao/data_analysis/VBM_5_6yo/VBM_touch/')
datadir = '/NOBACKUP/xiao/data_analysis/VBM_5_6yo/VBM_touch/';

% grey matter mask
[data Header] = y_Read(['5yo',filesep,'BH2K',filesep,'rc1avg_t1mprsagkids12Ch.nii']);
    new_data = zeros(size(data));
    new_data(data<0.2)=0;
    new_data(data>0) = 1;
    y_Write(data,Header,'mask.nii');
    
% absolute masking, with a threshold of 0.2
alldir = 'diff';
allimg = dir('diff');
data_all = zeros(240,256,128);
for i = 3:length(allimg)
    [data header] = y_Read([diff,filesep,allimg(i).name]);
    data_all = data + data_all;
    
end
data_all(find(data_all<0.2)) = 0; 
mean_img = allimg./allimg;  % average of all images
allimg(isnan(allimg))=0; 


% one sample t-test based on Jacobian difference between two time points

diff = {'diff'};

[TTest1_T,Header] = y_TTest1_Image(diff,'results/diff_new','AllResampled_GreyMask_03.nii','', '');  

% paried t-test
GMV_all = {['paired-t/6yo'];['paired-t/5yo']};


[TTest2_T,Header] = y_TTest2_Image(GMV_all,'paired-t','AllResampled_GreyMask_03.nii','', '');  
