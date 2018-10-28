
clear matlabbatch;

datadir = '/scr/loisach1/xiao/data_analysis/VBM_5_6yo/VBM_touch’;
all_fun = [datadir,filesep,'5yo'];
allimg = dir (all_fun) ;

[SPMPath, fileN, extn] = fileparts(which('spm.m'));
%-----------------------------------------------------------------------
% Job saved on 24-Jul-2016 20:09:26 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

% step 1: longitudinal registration, and obtain averaged image
for i = 3: length(allimg)
    datafile_5yo = [datadir,filesep,'5yo',filesep,allimg(i).name,filesep,'t1mprsagkids12Ch.nii,1'];
    datafile_6yo = [datadir,filesep,'6yo',filesep,allimg(i).name,filesep,'t1mprsagkids12Ch.nii,1'];
   
matlabbatch{1}.spm.tools.longit{1}.pairwise.vols1 = {datafile_5yo};
matlabbatch{1}.spm.tools.longit{1}.pairwise.vols2 = {datafile_6yo};
matlabbatch{1}.spm.tools.longit{1}.pairwise.tdif = 1;
matlabbatch{1}.spm.tools.longit{1}.pairwise.noise = NaN;
matlabbatch{1}.spm.tools.longit{1}.pairwise.wparam = [0 0 100 25 100];
matlabbatch{1}.spm.tools.longit{1}.pairwise.bparam = 1000000;
matlabbatch{1}.spm.tools.longit{1}.pairwise.write_avg = 1;
matlabbatch{1}.spm.tools.longit{1}.pairwise.write_jac = 1;
matlabbatch{1}.spm.tools.longit{1}.pairwise.write_div = 1;
matlabbatch{1}.spm.tools.longit{1}.pairwise.write_def = 0;

% step 2: segment with Old Segment precedure. Segment the subject average, generating c1, rc1, rc2 (for initial import)
matlabbatch{2}.spm.tools.oldseg.data(1) = cfg_dep('Pairwise Longitudinal Registration: Midpoint Average', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','avg', '()',{':'}));
matlabbatch{2}.spm.tools.oldseg.output.GM = [0 0 1];  % native 
matlabbatch{2}.spm.tools.oldseg.output.WM = [0 0 1];
matlabbatch{2}.spm.tools.oldseg.output.CSF = [0 0 1];
matlabbatch{2}.spm.tools.oldseg.output.biascor = 1;
matlabbatch{2}.spm.tools.oldseg.output.cleanup = 0;
matlabbatch{2}.spm.tools.oldseg.opts.tpm = {
                                            [SPMPath,filesep,'toolbox',filesep,'tpm_asy',filesep,'grey.nii,1']
                                            [SPMPath,filesep,'toolbox',filesep,'tpm_asy',filesep,'white.nii,1']
                                            [SPMPath,filesep,'toolbox',filesep,'tpm_asy',filesep,'csf.nii,1']
                                            };
matlabbatch{2}.spm.tools.oldseg.opts.ngaus = [2
                                              2
                                              2
                                              4];
matlabbatch{2}.spm.tools.oldseg.opts.regtype = 'mni';
matlabbatch{2}.spm.tools.oldseg.opts.warpreg = 1;
matlabbatch{2}.spm.tools.oldseg.opts.warpco = 25;
matlabbatch{2}.spm.tools.oldseg.opts.biasreg = 0.0001;
matlabbatch{2}.spm.tools.oldseg.opts.biasfwhm = 60;
matlabbatch{2}.spm.tools.oldseg.opts.samp = 3;
matlabbatch{2}.spm.tools.oldseg.opts.msk = {''};



% step 3: initial import. Images first need to be imported into a form that
% Dartel can work with. seg_sn.mat file contains the spatiall
% transformation and segmentation parameters. 
% produce rc1* and rc2*

  
Outputdir = [datadir,filesep,'5yo',filesep,allimg(i).name];

Matnamedir = dir([Outputdir,filesep,'*seg_sn.mat']); % initial import with seg_sn.mat file
Matnamefile = [Outputdir,filesep,Matnamedir(1).name];

matlabbatch{3}.spm.tools.dartel.initial.matnames = {Matnamedir};
matlabbatch{3}.spm.tools.dartel.initial.odir = {Matnamefile};
matlabbatch{3}.spm.tools.dartel.initial.bb = [NaN NaN NaN
                                              NaN NaN NaN];
matlabbatch{3}.spm.tools.dartel.initial.vox = 1.5;
matlabbatch{3}.spm.tools.dartel.initial.image = 0;
matlabbatch{3}.spm.tools.dartel.initial.GM = 1;
matlabbatch{3}.spm.tools.dartel.initial.WM = 1;
matlabbatch{3}.spm.tools.dartel.initial.CSF = 0;

% Step 4: Use ImCalc to compute c1.*jd (possibly dividing the result by the time difference to give the rate of atrophy)
matlabbatch{4}.spm.util.imcalc.input = {
                                        [Output, filesep,'avg_t1mprsagkids12Ch.nii,1']
                                        [Output, filesep, 'jd_t1mprsagkids12Ch_t1mprsagkids12Ch.nii,1']
                                        };
matlabbatch{4}.spm.util.imcalc.output = 'c1_jd';
matlabbatch{4}.spm.util.imcalc.outdir = {Outputdir};
matlabbatch{4}.spm.util.imcalc.expression = 'i1.*i2';
matlabbatch{4}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{4}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{4}.spm.util.imcalc.options.mask = 0;
matlabbatch{4}.spm.util.imcalc.options.interp = 1;
matlabbatch{4}.spm.util.imcalc.options.dtype = 4;

% step 5: run DARTEL, create template based on rc1 and rc2
matlabbatch{4}.spm.tools.dartel.warp.images{1}(1) = cfg_dep('Initial Import: Imported Tissue (GM)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles', '()',{':', 1}));
matlabbatch{4}.spm.tools.dartel.warp.images{2}(1) = cfg_dep('Initial Import: Imported Tissue (WM)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles', '()',{':', 2}));
matlabbatch{4}.spm.tools.dartel.warp.settings.template = 'Template';
matlabbatch{4}.spm.tools.dartel.warp.settings.rform = 0;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(1).its = 3;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
matlabbatch{4}.spm.tools.dartel.warp.settings.param(1).K = 0;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(1).slam = 16;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(2).its = 3;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
matlabbatch{4}.spm.tools.dartel.warp.settings.param(2).K = 0;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(2).slam = 8;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(3).its = 3;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
matlabbatch{4}.spm.tools.dartel.warp.settings.param(3).K = 1;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(3).slam = 4;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(4).its = 3;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
matlabbatch{4}.spm.tools.dartel.warp.settings.param(4).K = 2;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(4).slam = 2;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(5).its = 3;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
matlabbatch{4}.spm.tools.dartel.warp.settings.param(5).K = 4;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(5).slam = 1;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(6).its = 3;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
matlabbatch{4}.spm.tools.dartel.warp.settings.param(6).K = 6;
matlabbatch{4}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
matlabbatch{4}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
matlabbatch{4}.spm.tools.dartel.warp.settings.optim.cyc = 3;
matlabbatch{4}.spm.tools.dartel.warp.settings.optim.its = 3;

% step 6: normalization and smooth
matlabbatch{5}.spm.tools.dartel.mni_norm.template(1) = cfg_dep('Run Dartel (create Templates): Template (Iteration 6)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','template', '()',{7}));
matlabbatch{5}.spm.tools.dartel.mni_norm.data.subjs.flowfields(1) = cfg_dep('Run Dartel (create Templates): Flow Fields', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '()',{':'}));
matlabbatch{5}.spm.tools.dartel.mni_norm.data.subjs.images{1}(1) = cfg_dep('Image Calculator: ImCalc Computed Image: c1_jd', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{5}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
matlabbatch{5}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                               NaN NaN NaN];
matlabbatch{5}.spm.tools.dartel.mni_norm.preserve = 0;
matlabbatch{5}.spm.tools.dartel.mni_norm.fwhm = [8 8 8];


spm_jobman('run', matlabbatch)
end
