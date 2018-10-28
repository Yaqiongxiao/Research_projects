%% example: load data and visulization

s = SurfStatReadSurf( {...
     '/NOBACKUP/former_SCR2/VBM_freesurfer/data_analysis/ct/AL2K_5.long.AL2K/surf/lh.white', ... 
     '/NOBACKUP/former_SCR2/VBM_freesurfer/data_analysis/ct/AL2K_5.long.AL2K/surf/rh.white'} ); 
t = SurfStatReadData( {... 
     '/NOBACKUP/former_SCR2/VBM_freesurfer/data_analysis/ct/AL2K_5.long.AL2K/surf/lh.thickness', ... 
     '/NOBACKUP/former_SCR2/VBM_freesurfer/data_analysis/ct/AL2K_5.long.AL2K/surf/rh.thickness'} ); 
 
figure; SurfStatView( t, s, 'Cort Thick (mm), FreeSurfer data' ); 



%% surface based analysis  2017-01-31


export SUBJECTS_DIR=/NOBACKUP/former_SCR2/VBM_freesurfer/data_analysis/ct % type in terminal
SUBJ={'AL2K','BE4K'};

datadir = '/NOBACKUP/xiao/data_analysis/paper2_new_analysis/analysis_5yo/FunImgARWCF/';

fun_vol = [datadir, 'BS3K/Filtered_4DVolume.nii'];
stru_vol = ['BS3K_5.long.BS3K'];
mkdir(['/NOBACKUP/xiao/data_analysis/paper2_new_analysis/vol2surf_ARWCF/BS3K']);
reg_dat = ['/NOBACKUP/xiao/data_analysis/paper2_new_analysis/vol2surf_ARWCF/BS3K', filesep, 'reg_BS3K.dat'];
unix(['bbregister --s ',stru_vol,' --mov ',fun_vol,' --reg ',reg_dat,' --t1'])

unix(['tkregister2 --mov ', fun_vol,' --reg ',['/NOBACKUP/xiao/data_analysis/paper2_new_analysis/vol2surf_ARWCF/BS3K/reg_BS3K.dat'],' --surf']);

unix(['tkregister2 --mov ', fun_vol,' --reg ',['/NOBACKUP/xiao/data_analysis/paper2_new_analysis/vol2surf/BS3K/reg_BS3K.dat'],' --surf']);

% loop 

datadir = '/NOBACKUP/xiao/data_analysis/paper2_new_analysis/analysis_5yo/FunImgARW/';

datadir = '/NOBACKUP/xiao/data_analysis/paper2_new_analysis/analysis_5yo/FunImgARWCF/';
fun_all = dir(datadir);
lh_rh = {'lh','rh'};
for i = 3:length(fun_all)
    fun_vol = [datadir, fun_all(i).name, filesep, 'Filtered_4DVolume.nii'];
    stru_vol = [fun_all(i).name,'_5.long.',fun_all(i).name];
    mkdir(['/NOBACKUP/xiao/data_analysis/paper2_new_analysis/vol2surf/', fun_all(i).name]);
    % Step 1: register functional volume with structural volume
    reg_dat = ['/NOBACKUP/xiao/data_analysis/paper2_new_analysis/vol2surf/', fun_all(i).name, filesep, 'reg_', fun_all(i).name, '.dat'];
    % bbregister -s AL2K_5.long.AL5K --mov /NOBACKUP/xiao/data_analysis/paper2_new_analysis/analysis_5yo/FunImgARW/AL2K/wrat2starepi2Dresting.nii --reg register.dat 

    unix(['bbregister --s ',stru_vol,' --mov ',fun_vol,' --reg ',reg_dat,' --t2'])
    %unix(['tkregister2 --mov ',fun_vol,' ',' --s ',stru_vol,' --regheader',' --noedit', ' --reg ',reg_dat]); 
    % Step 2: convert volume to each surface vertex (freesurfer function, so initate freesurfer first)
    for s = 1:size(lh_rh,2)
        fname_out = ['/NOBACKUP/xiao/data_analysis/paper2_new_analysis/vol2surf/', fun_all(i).name, filesep, 'vol2suf_', fun_all(i).name, '_',lh_rh{s},'.mgh'];
        unix(['mri_vol2surf --mov ',fun_vol,' --reg ',reg_dat,' --hemi ', lh_rh{s}, ' --fwhm ',num2str(5), ' --surf ', 'white',' --o ', fname_out]); % only string is possible

    % unix(['mri_vol2surf --mov ',fun_vol,' --reg ',reg_dat,' --hemi ', 'lh', ' --fwhm ',num2str(5), ' --surf ', 'white',' --o ', fname_out]); % only string is possible
    end
end

% check register quality
unix(['tkregister2 --mov ', fun_vol,' --reg ',['/NOBACKUP/xiao/data_analysis/paper2_new_analysis/vol2surf/BS3K/reg_BS3K_tk.dat'],' --surf']) 

unix(['tkregister2 --mov ', fun_vol,' --reg ',['/NOBACKUP/xiao/data_analysis/paper2_new_analysis/vol2surf/EH1K/reg_EH1K.dat'],' --surf']) 


% Step 3: read surface data

file_EH1K = {'/NOBACKUP/xiao/data_analysis/paper2_new_analysis/vol2surf/EH1K/vol2surf_EH1K_lh.mgh', ...
    '/NOBACKUP/xiao/data_analysis/paper2_new_analysis/vol2surf/EH1K/vol2surf_EH1K_rh.mgh'};

Surf_EH1K_lh = SurfStatReadData({'/NOBACKUP/xiao/data_analysis/paper2_new_analysis/vol2surf/EH1K/vol2surf_EH1K_lh.mgh'});

% or Surf_BS3K = SurfStatReadData({'/NOBACKUP/xiao/data_analysis/paper2_new_analysis/vol2surf/BS3K/vol2surf_BS3K.mgh'});

s=SurfStatReadSurf({'/NOBACKUP/former_SCR2/VBM_freesurfer/data_analysis/ct/BS3K_5.long.BS3K/surf/lh.inflated', ...
    '/NOBACKUP/former_SCR2/VBM_freesurfer/data_analysis/ct/BS3K_5.long.BS3K/surf/rh.inflated'});

figure; SurfStatView(Surf_BS3K, s, 'surface');



%% step 4: statistical analysis using surfstat
Age = term(age);

M = 1 + Age + Gender


% find the number of different voxels
midx = ~~measrecon(:);
dvec = single(nii.img(midx)) - measrecon(midx);
NumDiffVox = sum(~~dvec);
pdv=NumDiffVox/sum(midx)*100; % percentage of voxels with difference values
disp(['> Total # of voxels altered by back-projection: ',...
 num2str(NumDiffVox),' (',num2str(pdv),' % of surface-mapped voxels)'])


% find the size of the biggest cluster
diffmap = double(nii.img*0);
mcs=0; % maximal cluster size
diffmap(midx) = double(nii.img(midx)) - double(measrecon(midx));
niid = nii;
niid.img= diffmap;
fnamed=[dir_exp,'/diffmap.test.orig_recon.nii'];
save_untouch_nii(niid, fnamed);
system(['cluster -t 1 -i ',fnamed,' > diff.test.clus.txt']);
fid = fopen('diff.test.clus.txt');
C= textscan(fid,repmat('%f',[1 9]),'headerlines',1);
mcs=max([mcs max(C{2})]);
niid.img= -diffmap;
fnamed=[dir_exp,'/diffmap.test.orig_recon.nii'];
save_untouch_nii(niid, fnamed);
system(['cluster -t 1 -i ',fnamed,' > diff.test.clus.txt']);
fid = fopen('diff.test.clus.txt');
C= textscan(fid,repmat('%f',[1 9]),'headerlines',1);
mcs=max([mcs max(C{2})]);
disp(['> Maximal size of clusters of voxels with different values between original and back-projected volume: ', ...
 num2str(mcs),' voxels']);

if ~~pdv>5 || ~~mcs>50
 ls(fname_recon);
 ls(fname_fslayers);
 error(['Something''s wrong with the volume <-> surface interpolation! Check the file above.']);
else
 system(['rm -f ',dir_exp,'/*.test.*']);
end
