function EXP = fsss_check_surfs(EXP)
% EXP = fsss_check_surfs(EXP)
%
% EXP requires:
%  .subjID
%  .seedname   'Nx1' anything between '[' and ']' will be only shown in
%  title but excluded in filenames
%  .fsdir
%  .fstemplate
%  .meastype
%  .fc
%  .caxis
%  .dir_figure
%
% (cc) 2015, sgKIM  mailto://solleo@gmail.com  https://ggooo.wordpress.com


seedsuffix = EXP.name_seed;
ind = strfind(seedsuffix,'/');
seedsuffix(ind) = '.';

% if ~isfield(EXP,'DoPc1'), EXP.DoPc1=1; end
% DoPc1      = EXP.DoPc1;
% if DoPc1,  Y1name='pc1'; else  Y1name='avg';  end
% seedsuffix=[seedsuffix,'-',Y1name];

if ~isfield(EXP,'fc'), EXP.fc=''; end
fwhmsuffix=['s',num2str(EXP.fwhm_mm),'mm'];
if ~isfield(EXP,'dir_figure')
  EXP.dir_figure = [EXP.fsdir,'/fig_',EXP.fc,'/',seedsuffix];
end

subjID = fsss_subjID(EXP.subjID);
N = numel(subjID);
if N==17
  ax = axeslayout1(N+1,[6,3]);
else
  ax = axeslayout1(N+1);
end
SIDE={'lh','rh'};
cfg=struct('sphere',0, 'inflated',1, 'mean',0, 'pial',0, 'ras',0, 'applyxfm',1, ...
  'area',1);
if ~isfield(EXP,'fstemplate'), EXP.fstemplate='fsaverage'; end
surf = fsss_read_all_FS_surfs(EXP.fstemplate, EXP.fsdir, cfg);
dir0 = fullfile(EXP.fsdir,EXP.fstemplate,EXP.meastype);
VIEWs = {[-115 4],[115 4]};

for s=1:2
  hf=figure('position',[1977 64 800 1028]);
  for n=1:N
    subjid = subjID{n};
    axespos(ax,n)
    % side, layer, meas, smoothing1, subject, (smoothing2)
    fname1=fullfile(dir0, ...
      [SIDE{s},'.k1.',seedsuffix,'-',EXP.fc,'.',fwhmsuffix,'.',subjid,'.mgz']);
    try ls(fname1)
    catch ME
      fname1=[EXP.fsdir,EXP.fstemplate,'/',EXP.meastype,'/',SIDE{s},'.k1.', ...
        EXP.meastype,'.',subjid,'.',fwhmsuffix, ...
        '.',seedsuffix,'-',EXP.fc,'.mgz'];
    end
    corry(n,:)=load_mgh(fname1);
    cfg2 = struct('cam',1, 'view',VIEWs{s}, 'caxis',EXP.caxis);
    cfg2.curv = surf.WHITECURV{s};
    view_trisurf(surf.INFLmni{s}, corry(n,:), cfg2);
    xlim0=xlim; ylim0=ylim; zlim0=zlim;
    if s==1
      x1=xlim0(1); y1=ylim0(2); z1=zlim0(2)*0.8;
    else
      x1=xlim0(2); y1=ylim0(1); z1=zlim0(2)*0.6;
    end
    text(x1,y1,z1, subjid,'fontsize',15)
    drawnow;
  end
  
  ha=axespos(ax,N+1);
  caxis(EXP.caxis);
  hb=colorbar('peer',ha, 'location','north'); axis off;
  xlabel(hb,['Pearson''s correlation'],'fontsize',12);
  set(hb,'fontsize',12)
  
  screen2png([EXP.dir_figure,'/',EXP.fc,'.',SIDE{s},'.',fwhmsuffix,'.all.png'], 200);
  close(hf);
end
end