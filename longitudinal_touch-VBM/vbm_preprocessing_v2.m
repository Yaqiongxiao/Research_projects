%% this version is an alternative for vbm_preprocess.m
%% rerun the longitudinal registration with 'serial' option to generate the
% Jacobian maps at the two time points

clear matlabbatch;

datadir = '/scr/loisach1/xiao/data_analysis/VBM_5_6yo/VBM_touch';
all_fun = [datadir,filesep,'5yo'];
allimg = dir (all_fun) ;
age = load([datadir,filesep,'age.txt']);

for i = 3:length(allimg)
Output_5y = [datadir,filesep,'5yo',filesep,allimg(i).name];
Output_6y = [datadir,filesep,'6yo',filesep,allimg(i).name];
matlabbatch{1}.spm.tools.longit{1}.series.vols = {
                                                  [Output_5y,filesep,'t1mprsagkids12Ch.nii,1']
                                                  [Output_6y,filesep,'t1mprsagkids12Ch.nii,1']
                                                  };
matlabbatch{1}.spm.tools.longit{1}.series.times = [5 6];
matlabbatch{1}.spm.tools.longit{1}.series.noise = NaN;
matlabbatch{1}.spm.tools.longit{1}.series.wparam = [0 0 100 25 100];
matlabbatch{1}.spm.tools.longit{1}.series.bparam = 1000000;
matlabbatch{1}.spm.tools.longit{1}.series.write_avg = 0;
matlabbatch{1}.spm.tools.longit{1}.series.write_jac = 1;
matlabbatch{1}.spm.tools.longit{1}.series.write_div = 1;
matlabbatch{1}.spm.tools.longit{1}.series.write_def = 0;
matlabbatch{2}.spm.util.imcalc.input = {
                                        [Output_5y,filesep,'c1avg_t1mprsagkids12Ch.nii,1']
                                        [Output_5y,filesep,'j_t1mprsagkids12Ch.nii,1']
                                        };
matlabbatch{2}.spm.util.imcalc.output = '5yo_c1';
matlabbatch{2}.spm.util.imcalc.outdir = {Output_5y};
matlabbatch{2}.spm.util.imcalc.expression = 'i1.*i2';
matlabbatch{2}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{2}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{2}.spm.util.imcalc.options.mask = 0;
matlabbatch{2}.spm.util.imcalc.options.interp = 1;
matlabbatch{2}.spm.util.imcalc.options.dtype = 4;
matlabbatch{3}.spm.util.imcalc.input = {
                                        [Output_5y,filesep,'c1avg_t1mprsagkids12Ch.nii,1']
                                        [Output_6y,filesep,'j_t1mprsagkids12Ch.nii,1']
                                        };
matlabbatch{3}.spm.util.imcalc.output = '6yo_c1';
matlabbatch{3}.spm.util.imcalc.outdir = {Output_6y};
matlabbatch{3}.spm.util.imcalc.expression = 'i1.*i2';
matlabbatch{3}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{3}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{3}.spm.util.imcalc.options.mask = 0;
matlabbatch{3}.spm.util.imcalc.options.interp = 1;
matlabbatch{3}.spm.util.imcalc.options.dtype = 4;

% normalise
flowdir = dir([Output_5y,filesep,'u_*.nii']);
flowfields = [Output_5y,filesep,flowdir(1).name];
matlabbatch{4}.spm.tools.dartel.mni_norm.template = {[Output_5y,filesep,'Template_6.nii']};
matlabbatch{4}.spm.tools.dartel.mni_norm.data.subjs.flowfields = {flowfields};
matlabbatch{4}.spm.tools.dartel.mni_norm.data.subjs.images = {
                                                              {[Output_5y,filesep,'5yo_c1.nii']}
                                                              {[Output_6y,filesep,'6yo_c1.nii']}
                                                              };
matlabbatch{4}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
matlabbatch{4}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                               NaN NaN NaN];
matlabbatch{4}.spm.tools.dartel.mni_norm.preserve = 0;
matlabbatch{4}.spm.tools.dartel.mni_norm.fwhm = [8 8 8];

spm_jobman('run', matlabbatch)
end
