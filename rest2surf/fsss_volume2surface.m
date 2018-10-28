 function EXP = fsss_volume2surface (EXP)
% EXP = fsss_volume2surface (EXP)
%
% This function is only a wrapper of mri_vol2surf;
% It samples the (registered) volume onto surfaces with a number of sanity checks.
% Use fsss_bbr.m for inter-modality coregistation if needed.
%
% EXP requires:
%  .subjID   = subject ID
%  .meastype = 'boldrest', 'boldloc', 'boldnat', 'qR1', 'qR1', 'md' (case-sensitive)
%  .fsdir    = /path/where/you/have/freesurfer/subjects where you have freesurfer subjects
%  .dataset  = the dataset name to find the 3-D images or give fname_vol
%  .projfrom = ['white'] or anything else in the 'surf' dir
%  .caxis
% (.interpopt)  'trilinear' or ['nearest']
%
% (cc) 2015. sgKIM. solleo@gmail.com

if ~nargin,   help fsss_volume2surface, return, end
global overwrite;  if isempty(overwrite),  overwrite=0;  end
[~,myname] = fileparts(mfilename('fullpath'));
disp(['### ',myname,': starting..']);

EXP.subjID  = fsss_subjID(EXP.subjID);
if ~isfield(EXP,'identity')||~isfield(EXP,'coreg_identity'),  EXP.coreg_identity = 0;  end
if ~isfield(EXP,'meastype'),  EXP.meastype='bold';  end
if ~isfield(EXP,'projfrom'),  EXP.projfrom = 'white'; end
if ~isfield(EXP,'volfwhm'),   volfwhmarg='';
else volfwhmarg=['--fwhm ',num2str(EXP.volfwhm)]; end
if ~isfield(EXP,'is3Tsurf_for_7T'),  EXP.is3Tsurf_for_7T=0;  end
K=3;   k1=1;   k2=3;  % one layer (50%) and two layers (25%/75%)
if isfield(EXP,'projk1k2'),  k1 = EXP.projk1k2(1);   k2 = EXP.projk1k2(2);  end
if ~isfield(EXP,'interpopt'), EXP.interpopt='nearest'; end

for n=1:numel(EXP.subjID)
 subjid = EXP.subjID{n};
 %% -1. fine measurement type
 meastype = EXP.meastype;
 switch meastype
  case {'boldloc','boldnat'} % 1.5 mm (better than 3 mm...)
   CAxis = [0 2000]; % for 7T slab
   K=1; k1=1; k2=1;
   if strcmp(meastype,'boldloc')
    EXP.numrun=6;
   elseif strcmp(meastype,'boldnat')
    EXP.numrun=2;
   end
  case {'boldrest','boldrestw','boldrest_f0inf'} % BOLD residual for 3T resing state fmri
   CAxis = [-100 100];
   if isfield(EXP,'preview1')||isfield(EXP,'preview2')
    CAxis = [0 15000];
   end
   K=1; k1=1; k2=1;
   % for 3T rest, [0 11000]
  case {'qR1'} % 0.7 mm
   CAxis = [0.4 0.6];
   meastype='qT1';
   butActuallyqR1 = 1;
   EXP.butActuallyqR1 = 1;
  case {'qT1'} % 0.7 mm
   CAxis = [0 4000];
  case 'md'  % 1.7 mm => 1 mm
   CAxis = [0  0.003];
 end
 if isfield(EXP,'caxis')
  CAxis=EXP.caxis;
 end
 
 %% find input volumes (based on ".dataset" name)
 if ~isfield(EXP,'dataset')
  EXP.dataset='Tonotopy';
 end
 
 switch EXP.dataset
  case 'Tonotopy'
   
   %load /scr/vatikan3/Tonotopy/mat/info34.mat subjID DIR7t %DIR3t
   load /scr/vatikan3/Tonotopy/mat/info43.mat subjID DIR7t
   j = find(subjID == str2double(subjid));
   % qT1 (7T)K
   if ~isfield(EXP,'fname_qT1')
    dir_7t = ['/scr/vatikan3/Tonotopy/main/',subjid,'/7T/',DIR7t{j}];
    [~,res] = mydir([dir_7t,'/*mp2rage_whole_brain*T1*.nii']);
    if isempty(res)
     [~,res] = mydir([dir_7t,'/mp2ragewholebrain8Chs004a1001.nii']);
    end
    %fname_qT1 = res{1};
    fname_qT1 = res;
   else
    fname_qT1=EXP.fname_qT1;
   end
      
   if ~isfield(EXP,'fsdir')
    EXP.fsdir='/scr/vatikan3/Myelin2/FS_7T_1mm_man_LhCorr.final';
   end
   
  case 'mp2_100'
   fname_qT1 = ['/scr/vatikan1/skim/mp2_100/mp2/',subjid,'_t1.nii'];
   
  case {'rsfc', 'rsfcw'}
   if ~isfield(EXP,'fsdir')
    EXP.fsdir='/scr/vatikan3/APConn/FSspm12/';
   end
   
  otherwise
   error('Unknown dataset name!');
 end
 
 fsdir = EXP.fsdir;
 if ~isfield(EXP,'dir_fig')
  EXP.dir_fig  = [fsdir,'/fig_coreg_',meastype];
 end
 [~,~] = mkdir(EXP.dir_fig);
 dir_fig = EXP.dir_fig;
 
 
 %% 0. set directories for this subject
 subjid = EXP.subjID{n};
 EXP.subjid = subjid;
 dir_exp = [fsdir,'/',subjid,'/',meastype];
 if exist('butActuallyqR1','var')
  dir_exp = [fsdir,'/',subjid,'/qR1'];
 end
 [~,~] = mkdir(dir_exp);
 EXP.dir_exp = dir_exp;
 
 %% 0.1. chek meanepi for bold
 if ~isempty(strfind(EXP.meastype,'bold')) && ~isfield(EXP,'notthistime')
  exp1=EXP;
  exp1.subjID={EXP.subjID{n}};
  exp1.notthistime=1;
  exp1.preview1=1;  % cmean epi (linear resampled)
  
  fsss_volume2surface(exp1);
  
  exp1=EXP;
  exp1.subjID={EXP.subjID{n}};
  exp1.notthistime=1;
  exp1.preview2=1;  % mean epi (not resampled)
  fsss_volume2surface(exp1);
  
  EXP.skipsanitycheck = 1; % because it's meaingless and takes too much time
 end
 
 %% 0.5 process each run
 if ~isfield(EXP,'numrun'), numrun = 1; else numrun=EXP.numrun; end
 
 for r = 1:numrun
  runidx = ['_run',num2str(r)];
  boldsuffix = [meastype(end-2:end),num2str(r)];
  % fix the value limit bug (it zeroes any values > 4000)
  if strcmp(meastype,'qT1')
   nii = load_untouch_nii(fname_qT1);
   nii.img(~nii.img) = 4000;
   trg = [dir_exp,'/qT1.nii'];
   save_untouch_nii(nii, trg);
   fname_vol = trg;
  elseif ~isempty(strfind(meastype,'bold'))
   fname_regdat = [dir_exp,'/bbr/',meastype,'_to_t1w',runidx,'.dat'];
   EXP.regarg = {[' --reg ',fname_regdat],[' --reg ',fname_regdat]};
   if ~isempty(strfind(meastype,'boldrest'))
    %fname_vol = [dir_exp,'/res.nii'];
    fname_vol = [dir_exp,'/res',runidx,'.nii'];
    if isfield(EXP,'preview1')
     fname_vol    = [dir_exp,'/cmeanepi.nii'];
     EXP.regarg  = {[' --regheader ',subjid], [' --identity ',subjid]};
    elseif isfield(EXP,'preview2')
     fname_vol    = [dir_exp,'/meanepi.nii'];
    end
   elseif strcmp(meastype,'boldloc') || strcmp(meastype,'boldnat')
    fname_vol = [dir_exp,'/au',boldsuffix,'.nii'];
    if isfield(EXP,'preview1')
     fname_vol    = [dir_exp,'/cmeanu',boldsuffix,'.nii'];
     EXP.regarg  = {[' --regheader ',subjid], [' --identity ',subjid]};
    elseif isfield(EXP,'preview2')
     fname_vol    = [dir_exp,'/meanu',boldsuffix,'.nii'];
    end
   end
  end
  
  % if using 3T surfaces
  if EXP.is3Tsurf_for_7T && (strcmp(meastype,'qR1') || strcmp(meastype,'qT1'))
   fname_vol = [dir_exp,'/rwqT1.nii'];
  end
  ls(fname_vol)
  EXP.fname_vol = fname_vol;
  
  %% 1. create tkm-slices (This is already done from fs_bbr; but qT1/qR1@7T on FS7T doesn't need bbr)
  cd(dir_exp);
  dir_tkm = [dir_fig,'/tkm_',meastype,'/'];
  [~,~] = mkdir(dir_tkm);
  [~,files] = mydir([dir_tkm,'/*',subjid,'*.tif']);
  if (overwrite || isempty(files)) && (~isempty(strfind(meastype,'bold')) && isfield(EXP,'preview1'))
   % (subjid, fname_qt1, outputdir, fsdir, measure, prefix, SLICE_INDEX, ZoomFactor)
   view_tkmslices(subjid, fname_vol, dir_tkm, fsdir, meastype, ['cmean',boldsuffix]);
  end
  
  %% 2-A: volume => surface
  if isempty(strfind(meastype,'bold'))
   regarg = fsss_native2fs (EXP);
  else
   regarg = EXP.regarg{1};
  end
  SIDE={'lh','rh'};
  for s=1:2
   for k=k1:1:k2
    projfrac = num2str(k/(K+1));
    if strcmp(meastype,'boldloc') || strcmp(meastype,'boldnat')
     fname_out = [dir_exp,'/',SIDE{s},'.k',num2str(k),'.',boldsuffix,'.mgz'];
    else
     fname_out =[dir_exp,'/',SIDE{s},'.k',num2str(k),'.',meastype,'.mgz'];
    end
    if ~exist(fname_out,'file') || overwrite
     unix(['mri_vol2surf --mov ',fname_vol,' ',regarg,' ',volfwhmarg,' ' , ...
      ' --hemi ',SIDE{s},' --surf ',EXP.projfrom,' --projfrac ',projfrac , ...
      ' --sd ',fsdir,' --interp ',EXP.interpopt,' --o ', fname_out]);
    end
    fname_bin = [dir_exp,'/',SIDE{s},'.k',num2str(k),'.bin.mgz'];
    if strcmp(meastype,'boldloc') || strcmp(meastype,'boldnat')
     fname_bin = [dir_exp,'/',SIDE{s},'.k',num2str(k),'.bin',num2str(r),'.mgz'];
    end
    if ~exist(fname_bin,'file') || overwrite
     mri = MRIread(fname_out);
     mri.vol = ~~mri.vol(:,:,:,1); % for fmri
     mri.frames = 1;               % for fmri
     MRIwrite(mri, fname_bin, '');
    end
   end
  end
  
  %% 2-B. now surface -> volume back: this MUST be a completely waste of time
  % and it's hard with the partial FOV
  if ~exist([dir_exp,'/fslayers_',num2str(k1),'_',num2str(k2),'.nii.gz'],'file') || overwrite
   if ~isfield(EXP,'skipsanitycheck') && (isempty(strfind(EXP.meastype,'bold')) && ~isfield(EXP,'notthistime'))
    logically_meaningless_checkup(EXP, K, k1, k2, r);
   end
  end
  
  %% 2+. compute qR1 from qT1
  if exist('butActuallyqR1','var')
   for s=1:2
    for k=k1:1:k2
     fname_qT1  = [dir_exp,'/',SIDE{s},'.k',num2str(k),'.qT1.mgz'];
     fname_qR1  = [dir_exp,'/',SIDE{s},'.k',num2str(k),'.qR1.mgz'];
     if ~exist(fname_qR1,'file') || overwrite
      mri= MRIread(fname_qT1);
      mri.vol = 1./(eps+double(mri.vol)./1000);
      mri.vol(mri.vol>1) = 1;
      MRIwrite(mri,fname_qR1,'bfloat');
     end
    end
    meastype='qR1';
   end
  end
  
  %% 3. But still surface-map would be good.
  preview='';
  if isfield(EXP,'preview1')
   preview='_meanc';
  elseif isfield(EXP,'preview2')
   preview='_mean';
  end
  if strcmp(meastype,'boldloc') || strcmp(meastype,'boldnat')
   fname_png = [dir_fig,'/surfs_',meastype,'/',subjid,preview,'_k',num2str(k2),'_r',num2str(r),'.png'];
  else
   fname_png = [dir_fig,'/surfs_',meastype,'/',subjid,preview,'_k',num2str(k2),'.png'];
  end
  if overwrite || ~exist(fname_png,'file')
   h=figure;
   for k=k1:1:k2
    clf;
    cfg1=[];
    cfg1.projfrom = EXP.projfrom;
    cfg1.projfrac = k/(K+1);
    layersurf = fsss_layer(subjid, fsdir, cfg1);
    
    for s=1:2
     fname_out =[dir_exp,'/',SIDE{s},'.k',num2str(k),'.',meastype,'.mgz'];
     if strcmp(meastype,'boldloc') || strcmp(meastype,'boldnat')
      fname_out = [dir_exp,'/',SIDE{s},'.k',num2str(k),'.',boldsuffix,'.mgz'];
     end
     [~,f1]=fileparts(fname_out);
     titletxt={[subjid,':',f1,'.',preview(2:end)],'';'Left','Right'};
     for si=1:2
      subplot(2,2,s+(si-1)*2)
      View={[-90 0],[90,0],[90 0],[-90,0]};
      cfg2=[];
      cfg2.view=View{s+(si-1)*2};
      cfg2.cam=1;
      cfg2.colormap=[1 1 1; jet(256)];
      cfg2.caxis = CAxis;
      x = load_mgh(fname_out,[],1);
      view_trisurf(layersurf{s}, squeeze(x), cfg2); axis on; box on;
      xlabel('Rgt'); ylabel('Ant'); zlabel('Sup');
      title(titletxt{si,s},'interp','none')
     end
    end
    haxes=axes('position',[0.555 -0.03 0.35 0.13]);
    colorbar('peer',haxes,'location','North');
    axis(haxes,'off'); caxis(CAxis);
    drawnow;
    [~,~] = mkdir([dir_fig,'/surfs_',meastype,'/']);
    screen2png(fname_png,150);
   end
   close(h);
  end
  
  %% 4. Slice-overlay of sampling point (layers) and origianl measures
  if K>1
   if strcmp(meastype,'boldloc') || strcmp(meastype,'boldnat')
    fname_fslayers = [dir_exp,'/fslayers_k',num2str(k1),'-',num2str(k2),'_r',num2str(r),'.nii.gz'];
   else
    fname_fslayers=[dir_exp,'/fslayers_',num2str(k1),'_',num2str(k2),'.nii.gz'];
   end
   try IMG = load_nii(fname_vol);
   catch exceptions
    IMG = load_untouch_nii(fname_vol);
   end
   try layers = load_nii(fname_fslayers);
   catch exceptions
    layers = load_untouch_nii(fname_fslayers);
   end
   
   if numel(size(IMG.img)) == 4
    IMG.img = mean(IMG.img,4);
   end
   % lots of slices
   cfg=[];
   cfg.SlicesDim=3;
   z = layers.hdr.dime.dim(3);
   cfg.SlicesRange=round([140 280]*z/320); % works for 0.7 mm (320 x 320 x 240)
   cfg.NumSlices=40;
   cfg.layout=[4 10];
   
   dim=size(IMG.img);
   cfg.FigPosition=[1         201        dim(1)*10         dim(2)*4];
   Nlevels=(k2-k1+1);
   cfg.colormap=[gray(25); prism(48)];
   if strcmp(meastype,'boldloc') || strcmp(meastype,'boldnat')
    fname_png = [dir_fig,'/fslayers/slices_t1w_k',num2str(k1),'-',num2str(k2),'_r',num2str(r),'_',subjid,'.png'];
   else
    fname_png = [dir_fig,'/fslayers/slices_t1w_k',num2str(k1),'-',num2str(k2),'_',subjid,'.png'];
   end
   if overwrite || ~exist(fname_png,'file')
    [H,h]=imageovermontage(IMG.img, layers.img, cfg);
    %colormap(cfg.colormap(2:end,:))
    CbAxes=[0.2 0.03 0.72 0.2/6*Nlevels*2];
    cbaxes=axes('position',CbAxes);
    h1 = colorbar('peer',cbaxes); axis(cbaxes,'off');
    colorbarYTickLabel={};
    S='LR';ti=1;
    for s=1:2
     for k=k1:1:k2
      colorbarYTickLabel{ti}=[S(s) num2str(round(k/K*100)) '%'];
      ti=ti+1;
     end
    end
    set(h1,'ytick',[1:(Nlevels*2)]+.5, 'yticklabel',colorbarYTickLabel, ...
     'Ycolor',[1 1 1], 'color','k');
    set(h,'color','k');
    [~,~] = mkdir([dir_fig,'/fslayers/']);
    screen2png(fname_png,150);
    close(h);
    
    % only a few LARGE slices
    cfg=[];
    cfg.SlicesDim=3;
    z = layers.hdr.dime.dim(3);
    cfg.SlicesRange=round([140 160]*z/240); % works for 0.7 mm (320 x 320 x 240)
    cfg.NumSlices=10;
    cfg.layout=[2 5];
    cfg.FigPosition=[1         201        dim(1)*5         dim(2)*2];
    %cfg.FigPosition=[1         201        1920         976];
    cfg.colormap=[gray(25); prism(48)];
    [H,h]=imageovermontage(IMG.img, layers.img, cfg);
    cbaxes=axes('position',[0.2 0.03 0.72 0.2]);
    h1 = colorbar('peer',cbaxes); axis(cbaxes,'off');
    set(h1,'ytick',[1:(Nlevels*2)]+.5, 'yticklabel',colorbarYTickLabel, ...
     'Ycolor',[1 1 1], 'color','k');
    set(h,'color','k');
    
    if strcmp(meastype,'boldloc') || strcmp(meastype,'boldnat')
     fname_png = [dir_fig,'/fslayers/largerslices_t1w_k',num2str(k1),'-',num2str(k2),'_r',num2str(r),'_',subjid,'.png'];
    else
     fname_png = [dir_fig,'/fslayers/largerslices_t1w_k',num2str(k1),'-',num2str(k2),'_',subjid,'.png'];
    end
    screen2png(fname_png,150);
    close(h);
   end
   disp([subjid,': done'])
  end
  
  if isfield(EXP,'preview1') || isfield(EXP,'preview2') || isfield(EXP,'preview3')
   for s=1:2
    for k=k1:1:k2
     projfrac = num2str(k/(K+1));
     if strcmp(meastype,'boldloc') || strcmp(meastype,'boldnat')
      fname_out = [dir_exp,'/',SIDE{s},'.k',num2str(k),'.',boldsuffix,'.mgz'];
     else
      fname_out =[dir_exp,'/',SIDE{s},'.k',num2str(k),'.',meastype,'.mgz'];
     end
     delete(fname_out);
    end
   end
  end
  
 end
 
end
[~,myname] = fileparts(mfilename('fullpath'));
disp(['### ',myname,': all done']);
end


%% ======================== SUBROUINTES ==============================


%%
function logically_meaningless_checkup(EXP, K, k1, k2, r)
% in other words, sanity-check-up

fname_vol = EXP.fname_vol;
dir_exp = EXP.dir_exp;
meastype = EXP.meastype;
if strcmp(EXP.meastype,'qR1')
 meastype='qT1';
end
SIDE={'lh','rh'};
if isempty(strfind(meastype,'bold'))
 regarg = fsss_native2fs (EXP);
else
 regarg = EXP.regarg{2};
end
fsdir=EXP.fsdir;

nii = load_untouch_nii (fname_vol);
fslayers  = double(nii.img*0); % empty matrix for FS layers
measrecon = double(nii.img*0); % empty matrix for measure-recon (NN-back)
fname_recon    = [dir_exp,'/',meastype,'-recon.test.nii.gz'];
fname_fslayers = [dir_exp,'/fslayers_',num2str(k1),'_',num2str(k2),'.nii.gz'];
if ~exist(fname_recon,'file') || ~exist(fname_fslayers,'file') || overwrite
 NumDiffVox_layer=zeros(1,6);
 RMS_layer=zeros(1,6);
 ki = 1;
 for s = 1:2
  disp([SIDE{s},':']);
  for k = k1:k2
   cfg.projfrac=k/(K+1);
   disp(['Surface -> volume at depth of ',num2str(cfg.projfrac*100),'% thickness']);
   % using mri_surf2vol, put back all, and check they are indentical
   % nn-ed measures
   %fname1  = [dir_exp,'/',SIDE{s},'.k',num2str(k),'.',meastype,'.mgz'];
   if strcmp(EXP.meastype,'boldloc') || strcmp(EXP.meastype,'boldnat')
    fname1 = [dir_exp,'/',SIDE{s},'.k',num2str(k),'.',meastype,num2str(r),'.mgz'];
    outvol1 = [dir_exp,'/recon.test.',meastype,'.ki',num2str(ki),'.r',num2str(r),'.nii'];
    fname2  = [dir_exp,'/',SIDE{s},'.k',num2str(k),'.bin',num2str(r),'.mgz'];
    outvol2 = [dir_exp,'/fslayer.test.ki',num2str(ki),'.r',num2str(r),'.nii'];
   else
    fname1 =[dir_exp,'/',SIDE{s},'.k',num2str(k),'.',meastype,'.mgz'];
    outvol1 = [dir_exp,'/recon.test.',meastype,'.ki',num2str(ki),'.nii.gz'];
    fname2  = [dir_exp,'/',SIDE{s},'.k',num2str(k),'.bin.mgz'];
    outvol2 = [dir_exp,'/fslayer.test.ki',num2str(ki),'.nii.gz'];
   end
   
   system(['mri_surf2vol --surfval ',fname1,' --hemi ',SIDE{s}, ...
    ' --projfrac ',num2str(cfg.projfrac), regarg, ...
    ' --sd ',fsdir,' --template ',fname_vol,' --o ',outvol1]);
   nii1 = load_untouch_nii(outvol1);
   measrecon(~~nii1.img(:)) = nii1.img(~~nii1.img(:));
   
   % fslayer index
   system(['mri_surf2vol --surfval ',fname2,' --hemi ',SIDE{s}, ...
    ' --projfrac ',num2str(cfg.projfrac), regarg, ...
    ' --sd ',fsdir,' --template ',fname_vol,' --o ',outvol2]);
   nii2 = load_untouch_nii(outvol2);
   fslayers(~~nii2.img(:)) = nii2.img(~~nii2.img(:)) * ki;
   
   idx = ~~nii1.img;
   NumDiffVox_layer(ki) = sum(single(nii.img(idx)) ~= nii1.img(idx));
   disp(['> # of diff vox= ',num2str(NumDiffVox_layer(ki))]);
   RMS_layer(ki) = rms(single(nii.img(idx)) - nii1.img(idx));
   disp(['> RMS of diff = ',num2str(RMS_layer(ki))]);
   
   ki = ki + 1;
  end
 end
 nii1.img = measrecon;
 save_untouch_nii(nii1, fname_recon);
 nii2.img = fslayers;
 save_untouch_nii(nii2, fname_fslayers);
end
nii1 = load_untouch_nii(fname_recon);
measrecon = nii1.img;

% find the number of different voxels
midx = ~~measrecon(:);
dvec = single(nii.img(midx)) - measrecon(midx);
NumDiffVox = sum(~~dvec);
pdv=NumDiffVox/sum(midx)*100; % percentage of voxels with difference values
disp(['> Total # of voxels altered by back-projection: ',...
 num2str(NumDiffVox),' (',num2str(pdv),' % of surface-mapped voxels)']);

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


end