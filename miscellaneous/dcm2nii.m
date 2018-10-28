%% dcm2nii  20160725
cd ('/scr/loisach1/xiao/data_analysis/VBM_5_6yo/VBM_touch/extra')
datadir = '/scr/loisach1/xiao/data_analysis/VBM_5_6yo/VBM_touch/extra';
% cd([datadir,filesep,'5yo',filesep,'TJ1K']);
OutputDir_5yo = [datadir,filesep,'5yo',filesep,'T1Img',filesep,'TJ1K'];
OutputDir_6yo = [datadir,filesep,'6yo',filesep,'T1Img',filesep,'TJ1K'];
mkdir(OutputDir_5yo)
mkdir(OutputDir_6yo)
dirdcm_5yo = dir([datadir,filesep,'5yo',filesep,'TJ1K',filesep,'*']);
dirdcm_6yo = dir([datadir,filesep,'6yo',filesep,'TJ1K',filesep,'*']);

InputFilename_5yo=[datadir,filesep,'5yo',filesep,'TJ1K',filesep,dirdcm_5yo(3).name];

InputFilename_6yo=[datadir,filesep,'6yo',filesep,'TJ1K',filesep,dirdcm_6yo(3).name];

y_Call_dcm2nii(InputFilename_5yo, OutputDir_5yo, 'DefaultINI');
y_Call_dcm2nii(InputFilename_6yo, OutputDir_6yo, 'DefaultINI');
