%% check coregistration

%-----------------------------------------------------------------------
% Job saved on 27-Jul-2016 11:15:58 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
%%
clear matlabbatch
datadir = '/scr/loisach1/xiao/Chinese_children/new_analysis/sym_new/FunImgARWSDCFsym';
allimg = dir(datadir);

matlabbatch{1}.spm.util.checkreg.data = {
    [datadir,filesep, allimg(3).name,filesep,'sym_niftiDATA_Subject001_Condition001.nii']
    [datadir,filesep, allimg(4).name,filesep,'sym_niftiDATA_Subject002_Condition001.nii']
    };
 
spm_jobman('run', matlabbatch);



datadir = '/scr/loisach1/xiao/Chinese_children/new_analysis/asym_analysis/FunImgARW';
allimg=dir(datadir);
FileList = [];
for i = 3:17
    Filedir = dir([datadir,filesep,allimg(i).name,filesep,'*.img']);
    FileList = [FileList;{[datadir,filesep,allimg(i).name,filesep,Filedir(1).name,',1']}];
end
    
matlabbatch{1}.spm.util.checkreg.data = FileList;
 
spm_jobman('run', matlabbatch);

clear matlabbatch

FileList = [];
for i = 18:32
    Filedir = dir([datadir,filesep,allimg(i).name,filesep,'*.img']);
    FileList = [FileList;{[datadir,filesep,allimg(i).name,filesep,Filedir(1).name,',1']}];
end
        
matlabbatch{1}.spm.util.checkreg.data = FileList;
 
spm_jobman('run', matlabbatch);