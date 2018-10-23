%-----------------------------------------------------------------------
% Job saved on 22-Jul-2016 19:57:09 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
%%
datadir = '/scr/loisach1/xiao/data_analysis/';

for i = 3:length(allimg)
FileDir = dir([datadir,'5yo',filesep,allimg(i),name,filesep,'*.img'])

FileDir = dir([datadir,'5yo',filesep,allimg(i),name,filesep,'*.img'])

for j = 1:length(FileDir)
FileList={FileList;{[datadir,'5yo',filesep,allimg(i).name,filesep,FileDir(j).name]}}
end

matlabbatch{1}.spm.util.cat.vols = FileList;
matlabbatch{1}.spm.util.cat.name = 'ra_epi.nii';
matlabbatch{1}.spm.util.cat.dtype = 4;
spm_jobman('run', matlabbatch);