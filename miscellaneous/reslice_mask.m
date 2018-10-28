%%% reslice mask

cd('/scr/loisach1/xiao/data_analysis/VBM_5_6yo/VBM_touch/')
datadir = '/scr/loisach1/xiao/data_analysis/VBM_5_6yo/VBM_touch/';

        RefDir = dir([datadir,'diff',filesep,'*.nii']);
        RefFile=[datadir,'diff',filesep,RefDir(1).name];
        [RefData,RefVox,RefHeader]=y_ReadRPI(RefFile,1); % read data


        AMaskFilename = [datadir,'GreyMask_03.nii'];
                
        [pathstr, name, ext] = fileparts(AMaskFilename);
        ReslicedMaskName=[datadir,'AllResampled_',name,'.nii'];
        
        y_Reslice(AMaskFilename,ReslicedMaskName,RefVox,0, RefFile);
