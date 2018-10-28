function EXP = fsss_rsfc_seed (EXP)
% EXP = fsss_rsfc_seed(EXP)
%
% EXP requires:
%  .subjID
%  .fwhm_edge
% (.fstemplate) 'Nx1' 'fsaverage6' (default)
%
% - seed needs to be defined either:
%  .fname_seed
% (.seedidx)    [1x1] 1 (default)
% or
%  .circle_seed
% or
%  .aparc_seed 
% (.fwhm0) for smoothing on native surfaces
%  .onfsvag     [1x1] computing correlation on fs-average (1; default)
%                     or native surface (0)
%
% (.nofigure)
% (cc) 2015. sgKIM. solleo@gmail.com

if ~nargin,  help fsss_rsfc_seed; return; end
EXP=fsss_preset(EXP); % preset for AP-Conn
if ~isfield(EXP,'meastype'), EXP.meastype='boldrest'; end
if ~isfield(EXP,'fstemplate'), EXP.fstemplate='fsaverage6'; end
if ~isfield(EXP,'caxis'), EXP.caxis=[-.5 .5]; end
if ~isfield(EXP,'nofigure'), EXP.nofigure=0; end
if ~isfield(EXP,'fc'), EXP.fc='cor'; end
if ~isfield(EXP,'onfsavg'), EXP.onfsavg=1; end
if ~isfield(EXP,'overwrite'), EXP.overwrite=0; end

% set local variables
meastype   = EXP.meastype;
fsdir      = EXP.fsdir;
fstemplate = EXP.fstemplate;
num_subjN  = numel(EXP.subjID);
subjID     = fsss_subjID(EXP.subjID);
onfsavg    = EXP.onfsavg;
overwrite  = EXP.overwrite;

for n=1:num_subjN
 subjid = subjID{n};
 dir1 = fullfile(fsdir,subjid,meastype);
 dir0 = fullfile(fsdir,fstemplate,meastype);


 %% 0.1. load surfaces
 cfg=struct('sphere',0, 'inflated',1, 'mean',0, 'pial',0, 'ras',0, ...
  'applyxfm',1, 'area',1);
 if onfsavg
  EXP.SURF = read_all_FS_surfs(fstemplate, fsdir, cfg);
 else
  EXP.SURF = read_all_FS_surfs(subjid, fsdir, cfg);
 end
 


 %% 0.2. set # of layers and sides
 SIDE={'lh','rh'};
 
 %% 1A. surface-based smoothing on native surface
 if ~onfsavg
  exp1=EXP;
  exp1.subjid = subjid;
  exp1 = fsss_smooth(exp1);
  EXP.fname_SY = exp1.fname_SY;
  fwhmsuffix=['s',num2str(EXP.fwhm_mm),'mm'];
  dir0 = fullfile(fsdir, subjid, meastype);
 else


  %% 1B. normalize onto template & smooothing
  for s=1:2
   dir0 = fullfile(fsdir, subjid, meastype);
   dir1 = fullfile(fsdir, fstemplate, meastype);
   if ~exist(dir0,'dir'), mkdir(dir0); end
   if ~exist(dir1,'dir'), mkdir(dir1); end
   src  = fullfile(dir0,[SIDE{s},'.k1.',meastype,'.mgz']);
   fwhmsuffix=['s',num2str(EXP.fwhm_mm),'mm'];
   trg  = fullfile(dir1,[SIDE{s},'.k1.',meastype,'.',subjid,'.', ...
    fwhmsuffix,'.mgz']);
   if ~exist(trg,'file')
    disp(['> normalizing & smoothing: ',trg]);
    unix(['mri_surf2surf --srcsubject ',subjid,' --sval ',src, ...
     '  --trgsubject ',fstemplate,' --tval ',trg,' --hemi ',SIDE{s}, ...
     ' --fwhm-trg ',num2str(EXP.fwhm_mm)])
   end
   doesexist(trg);
   EXP.fname_SY{1,s}=trg;
  end
 end
 


 %% 2. find seed (from fsavg or indi ) and extract timeseries
 if onfsavg
  fname_seed = fullfile(fsdir,fstemplate,EXP.name_seed);
 else
  fname_seed = fullfile(fsdir,subjid,EXP.name_seed);
 end
 
 if ~isfield(EXP,'seed_idx'),
  seed_idx = 1;
 else
  seed_idx = EXP.seed_idx;
 end
 if strcmp(fname_seed(end-2:end-1),'mg')
  idx1 = round( load_mgh(fname_seed))==seed_idx ;
 else
  idx1 = round( read_curv(fname_seed))==seed_idx;
 end
 seedsuffix = EXP.name_seed;
 ind = strfind(seedsuffix,'/');
 seedsuffix(ind) = '.';
 if ~isempty(strfind(seedsuffix,'lh')), s=1; else s=2; end
 


 %% 3. extract PC1 (or mean), check the sign
 dir_figure = [fsdir,'/fig_corr/',seedsuffix,'/'];
 fname_fig_pc1=[dir_figure, ...
  '/seed_',seedsuffix,'.',fwhmsuffix,'.',subjid,'.png'];
 if ~EXP.nofigure && ~exist(fname_fig_pc1,'file')
  ax=axeslayout1(4,[],[0.001 0.001]);
  hf=figure('position',[1923         204         543         339]);
  vals = (EXP.SURF.WHITECURV{s}>0)+2*idx1;
  VIEWs = {{[-90 40],[90 -20]},{[90 40],[-90 -20]}};
  axespos(ax,1);
  cfg1=struct('caxis',[0 3], 'cam',1, 'view',VIEWs{s}{1}, ...
   'colormap',[1 1 1; .8 .8 .8; 1 0 0; 1 0 0]);
  view_trisurf(EXP.SURF.INFLmni{s}, vals, cfg1);
  axespos(ax,2);
  cfg1.view=VIEWs{s}{2};
  view_trisurf(EXP.SURF.INFLmni{s}, vals, cfg1);
 end
 
 % read smoothed data
 sy = squeeze(load_mgh(EXP.fname_SY{1,s}))';
 [U1,~,~] = svd(sy(:,idx1),'econ');  % find pc1
 y1 = (U1(:,1));  % no zscoring?
 %     y1 = zscore(U1(:,1));  % zscoring?
 a1 = mean(sy(:,idx1),2);
 if corr(y1,a1) < 0
  y1=-y1;
 end
 % y1 = pc1(sy);
 
 % (seed activitiy) file name: side, layer, meas, smoothing, subjid
 fname_y1 = [dir1,'/seedPC1.',seedsuffix,'.',fwhmsuffix,'.',subjid,'.mgz'];
 if ~exist(fname_y1,'file') || overwrite
  disp(['> saving seed PC1: ',fname_y1]);
  save_mgh(y1, fname_y1, eye(4));
 end
 
 if ~EXP.nofigure && ~exist(fname_fig_pc1,'file')
  subplot(2,2,[3,4])
  plot(y1); xlim([1 size(y1,1)]);
  title([subjid,':',seedsuffix],'fontsize',15)
  ylabel('Z(PC#1)'); xlabel('TR');
  [~,~] = mkdir(dir_figure);
  screen2png(fname_fig_pc1,100);
  close(hf);
 end
 
 %% 4. now read "smoothed" data
 for s = 1:2
  sy = squeeze(load_mgh(EXP.fname_SY{1,s}));
  if size(sy,1) ~= size(y1,1)
   sy = sy';
  end
  %% 5. compute functional connectivity (corr, abscorr, cohere)
  % naming convetion: side, layer, meas, smoothing,
  switch EXP.fc
   case 'cor'
    filename_fc=[SIDE{s},'.k1.', EXP.meastype,'.',subjid, ...
     '.',fwhmsuffix,'.',seedsuffix,'-',EXP.fc,'.mgz'];
   case 'coh'
    filename_fc=[SIDE{s},'.k1.', EXP.meastype,'.',subjid, ...
     '.',fwhmsuffix, '.',seedsuffix,'-',EXP.fc,'.allFreq.mgz'];
   case 'xcor'
    %disp(['BPF: [9,80] mHz = between [12.5, 111.1] sec => 111.1/1.4(TR) = 10 ~ 79.3 samples'])
    if ~isfield(EXP,'numlags')
     numlags=80;
    else
     numlags=EXP.numlags;
    end
    numbins=numlags*2+1;
    filename_fc=[SIDE{s},'.k1.', EXP.meastype,'.',subjid, ...
     '.',fwhmsuffix, '.',seedsuffix,'-',EXP.fc,'.',num2str(numbins),'bins.mgz'];
  end
  if onfsavg
   dir_out = dir1;
  else
   dir_out = dir0;
  end
  fname_fc = fullfile(dir_out, filename_fc);
  
  if ~exist(fname_fc,'file') || overwrite
   switch EXP.fc
    case 'cor'  % for BPF [0.009, 0.08]
     fc = corr(y1,sy)';
     disp(['> saving Pearson correlation: ',fname_fc]);
     save_mgh(fc,fname_fc);
     
    case 'coh'
     v=1;
     NFFT=256*2;
     %tic
     [~,Hz] = mscohere (y1, sy(:,v), [], [], NFFT, 1/EXP.TR);
     % toc % 0.013 seconds... takes 18 hours, not so bad.
     mHz=Hz*1000;
     fname_mHz = [dir_out,'/NFFT256_all_mHz.txt'];
     dlmwrite(fname_mHz, mHz);
     % vertex by freq-bin (>14K, 129)
     numv = size(sy,2);
     fc = zeros(numv, numel(Hz)); % 10242 x 257
     disp('# computing coherence...');
     tic
     for v=1:numv
      Cxy = mscohere (y1, sy(:,v), [], [], NFFT, 1/EXP.TR);
      fc(v,:) = Cxy;
     end
     toc
     disp(['> saving cross-coherence: ',fname_fc]);
     save_mgh(fc, fname_fc);
     
    case 'xcor'
     v=1;
     numv = size(sy,2);
     XC     = zeros(numv, numbins); % 10242 x 257
     BD_sec = zeros(numv, 1); % 10242 x 257
     maxXC  = zeros(numv, 1); % 10242 x 257
     BD_sec_abs = zeros(numv, 1); % 10242 x 257
     maxXC_abs  = zeros(numv, 1); % 10242 x 257
     
     disp('# computing cross-correlation...');
     tic
     for v=1:numv
      % BPF: [9,80] mHz = between [12.5, 111.1] sec => 111.1/1.4(TR) = 79.3 samples
      [XC(v,:), lag_tr, bounds] = crosscorr(y1, sy(:,v), numlags);
      % max coherence
      [maxXC(v),idx] = max(XC(v,:));
      BD_sec(v) = lag_tr(idx) * EXP.TR;
      % max absolute coherence
      [maxXC_abs(v),idx] = max(abs(XC(v,:)));
      BD_sec_abs(v) = lag_tr(idx) * EXP.TR;
     end
     toc
     lag_sec = lag_tr * EXP.TR;
     fname_sec = [dir_out,'/xcorr_lags_sec.txt'];
     dlmwrite(fname_sec, lag_sec);
     
     fname_bnd = [dir_out,'/xcorr_bounds.txt'];
     dlmwrite(fname_bnd, bounds);
     
     disp(['> saving cross-correlation: ',fname_fc]);
     save_mgh(XC, fname_fc);
     
     filename_fc=[SIDE{s},'.k1.', EXP.meastype,'.',subjid, ...
      '.',fwhmsuffix, '.',seedsuffix,'-',EXP.fc,'.bestDealy.mgz'];
     fname_BD = fullfile(dir_out, filename_fc);
     disp(['> saving best delay map: ',fname_BD]);
     save_mgh(BD_sec, fname_BD);
     
     filename_fc=[SIDE{s},'.k1.', EXP.meastype,'.',subjid, ...
      '.',fwhmsuffix, '.',seedsuffix,'-',EXP.fc,'.bestDealy.abs.mgz'];
     fname_BD = fullfile(dir_out, filename_fc);
     disp(['> saving best delay map from abs(xcor): ',fname_BD]);
     save_mgh(BD_sec_abs, fname_BD);
     
   end
  end
  
  % averaging squared magnitude of coherence within a given band
  if strcmpi(EXP.fc,'coh')
   mHz = dlmread([dir_out,'/NFFT256_all_mHz.txt']);
   fc=load_mgh(fname_fc);
   fname_fc_band0='';
   
   % now average across bands
   tic
   B=numel(EXP.cohbands_mHz);
   for b=1:B
    idx1=find(mHz>=EXP.cohbands_mHz{b}(1),1,'first');
    idx2=find(mHz<=EXP.cohbands_mHz{b}(2),1,'last');
    if idx1 > idx2
     tmp=idx2;
     idx2=idx1;
     idx1=tmp;
    end
    if isfield(EXP,'band_idx')
     idx1=EXP.band_idx(b,1);
     idx2=EXP.band_idx(b,2);
    end
    EXP.actual_cohbands_mHz{b} = [round(mHz(idx1)), round(mHz(idx2))];
    EXP.actual_cohbands_mHz_notRounded{b} = [mHz(idx1), mHz(idx2)];
    EXP.freq_bin_num(b) = idx2-idx1+1;
    EXP.actual_bins{b} = [idx1 idx2];
    bandstr=[pad(round(mHz(idx1)),3),'-',pad(round(mHz(idx2)),3),'mHz'];
    fname_fc_band = [dir_out,'/',SIDE{s},'.k1.b',num2str(b),'-',num2str(B),'.', ...
     EXP.meastype,'.',subjid,'.',fwhmsuffix, '.',seedsuffix,'-',EXP.fc,'.', ...
     bandstr,'.mgz'];
    if ~exist(fname_fc_band,'file')
     disp(['saving: ',fname_fc_band]);
     coh = mean(fc(:,[idx1:idx2]),2);
     if sum(isnan(coh))
      error('why nan?!');
     end
     save_mgh(coh, fname_fc_band);
    end
    % compute correlation between previous FC and current FC maps
    if b>1
     fc0 = load_mgh(fname_fc_band0);
     fc1 = load_mgh(fname_fc_band);
     EXP.CohMapsCorr(b,s,n) = corr(fc0,fc1);
    end
    fname_fc_band0=fname_fc_band;
   end
  end
  
  % averaging x-corr across lags
  if strcmp(EXP.fc,'xcor')
   if ~isfield(EXP,'binwidth_sec')
    binwidth_sec=20;
   else
    binwidth_sec=EXP.binwidth_sec;
   end
   
   XC=load_mgh(fname_fc);
   
   fname_sec = [dir_out,'/xcorr_lags_sec.txt'];
   lag_sec=dlmread(fname_sec);
   L=numel(lag_sec);
   idx0=(L-1)/2+1;
   halfbin=round(binwidth_sec/EXP.TR/2);
   idx_c=unique([sort(-[0:halfbin:((L/2)-halfbin)]), ...
    [0:halfbin:((L/2)-halfbin)]] +idx0);
   idx1=idx_c - halfbin;
   idx2=idx_c + halfbin;
   B=numel(idx1);
   for b=1:B
    lagstr=[num2str(round(lag_sec(idx1(b)))),'_', ...
     num2str(round(lag_sec(idx2(b)))),'sec'];
    fname_fc_lag = [dir_out,'/',SIDE{s},'.k1.b',num2str(b),'-',num2str(B),'.', ...
     EXP.meastype,'.',subjid,'.',fwhmsuffix, '.',seedsuffix,'-',EXP.fc,'.', ...
     lagstr,'.mgz'];
    if ~exist(fname_fc_lag,'file')
     disp(['saving: ',fname_fc_lag]);
     xcor = mean(XC(:,[idx1(b):idx2(b)]),2);
     if sum(isnan(xcor))
      error('why nan?!');
     end
     save_mgh(xcor, fname_fc_lag);
    end
   end
  end
 end % of side-loop
end % of subject-loop
end

function EXP=fsss_preset(EXP)
% preset for AP-Conn
if isfield(EXP,'APConn') || isfield(EXP,'APConnEuro')
 load /scr/vatikan3/APConn/mat/info17s.mat subjID AP ethn movmax APS
 EXP.fsdir = '/scr/vatikan3/APConn/FSspm12/';
 EXP.fstemplate = 'fsaverage5';
 EXP.fwhm_mm = 10; % fwhm_mm
 EXP.subjID     = subjID;
 EXP.name_seed  = 'qR1/rh.AP.sig';
 EXP.subjID     = subjID;
 
 % presets for measure
 if strcmpi(EXP.fc,'coh')
  EXP.meastype   = 'boldrest_f0inf';
 else
  EXP.meastype   = 'boldrest';
 end
end

if ~isfield(EXP,'cohbands_mHz')
 if isfield(EXP,'upto')
  upto=EXP.upto;
 else
  upto=100;
 end
 if isfield(EXP,'bandwidth')
  bandwidth = EXP.bandwidth;
 else
  bandwidth = 2; % 256+1 bins (max diff=1.4)
 end
 hbw=bandwidth/2;
 CF=[hbw:(2*hbw):upto];
 EXP.cohbands_mHz={};
 for b=1:numel(CF)
  EXP.cohbands_mHz {b} = ([CF(b)-hbw, CF(b)+hbw]);
 end
end

end
