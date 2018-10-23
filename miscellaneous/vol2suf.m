%% convert volume data to surface using freesurfer functions
% two steps: registration and convert
% initiate freesurfer first and export SUBJECTS_DIR=/where/is/the/structual/data

datadir = '/where/is/the/functional/file';
fun_all = dir(datadir);
lh_rh = {'lh','rh'};
for i = 3:length(fun_all)
    fun_vol = [datadir, fun_all(i).name, filesep, 'Filtered_4DVolume.nii'];
    stru_vol = [fun_all(i).name,'_5.long.',fun_all(i).name];
    mkdir(['/where/is/the/output/directory/', fun_all(i).name]);
    % Step 1: register functional volume with structural volume
    reg_dat = ['/where/is/the/output/directory/', fun_all(i).name, filesep, 'reg_', fun_all(i).name, '.dat'];
    % bbregister -s subj --mov fun.nii --reg register.dat 

    unix(['bbregister --s ',stru_vol,' --mov ',fun_vol,' --reg ',reg_dat,' --t2'])
    %unix(['tkregister2 --mov ',fun_vol,' ',' --s ',stru_vol,' --regheader',' --noedit', ' --reg ',reg_dat]); 
    
    % Step 2: convert volume to each surface vertex 
    for s = 1:size(lh_rh,2)
        fname_out = ['/where/is/the/output/directory/', fun_all(i).name, filesep, 'vol2suf_', fun_all(i).name, '_',lh_rh{s},'.mgh'];
        unix(['mri_vol2surf --mov ',fun_vol,' --reg ',reg_dat,' --hemi ', lh_rh{s}, ' --fwhm ',num2str(5), ' --surf ', 'white',' --o ', fname_out]); % only string is possible

    % unix(['mri_vol2surf --mov ',fun_vol,' --reg ',reg_dat,' --hemi ', 'lh', ' --fwhm ',num2str(5), ' --surf ', 'white',' --o ', fname_out]); % only string is possible
    end
end

% check register quality
unix(['tkregister2 --mov ', fun_vol,' --reg ',['/where/is/the/output/directory/BS3K/reg_BS3K_tk.dat'],' --surf']) 

unix(['tkregister2 --mov ', fun_vol,' --reg ',['/where/is/the/output/directory/EH1K/reg_EH1K.dat'],' --surf']) 
