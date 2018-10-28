% Retrieves the event-related timecourse for a region of interest
% NOTE: Assumes the canonical HRF with no spatial or temporal derivatives.
%
% Peter Zeidman
% v2

% -------------------------------------------------------------------------
% Settings (change these as needed)
% -------------------------------------------------------------------------

spm_directory = 'C:\original_experiments\attention\attention\GLM\';
mask_filename = 'C:\original_experiments\attention\attention\GLM\occipital2.nii';

xG            = struct();
xG.spec.Sess  = 1;                           % Session number
xG.spec.u     = 1;                           % Column in the design matrix
xG.spec.Rplot = 'fitted response and PSTH';  % Plot type (see spm_graph)
xG.def        = 'Event-related responses';   % Action (see spm_graph)

% -------------------------------------------------------------------------
% Get data
% -------------------------------------------------------------------------

% Read mask
V = spm_vol(mask_filename);
[Y,XYZmm] = spm_read_vols(V);

% Identify in-mask voxels
idx = find(Y(:) > 0.5);

% Enter SPM directory and load SPM
start_dir = pwd;
cd(spm_directory);
load(fullfile(spm_directory,'SPM.mat'));

% Initialize graphics
spm_progress_bar('Init',length(idx),'','Voxels');

clear PSTH;
clear fitted;

for i = 1:length(idx)
    
    spm_progress_bar('Set',i); 
    
    % Get mm coordinates for this voxel
    mm = XYZmm(:, idx(i));
    
    % Convert mm -> voxel coordinates
    XYZ = round(SPM.Vbeta(1).mat \ [mm; 1]);
    XYZ = XYZ(1:3);
    
    % Get timeseries
    [Y,y,beta,Bcov,G] = spm_graph(SPM,XYZ,xG);
    
    % Peri-stimulus time histogram
    PSTH(:,i) = G.PSTH;
    
    % Fitted response (prediction)
    fitted(:,i) = Y;
            
end

spm_progress_bar('Clear');

% Return home
cd(start_dir);

% -------------------------------------------------------------------------
% Plot
% -------------------------------------------------------------------------

spm_figure('GetWin','ROI Peri-Stimulus Time Histogram');
spm_clf; 
subplot(2,1,1);
spm_plot_ci(mean(PSTH'),var(PSTH'),G.PST, [], 'b--o');
hold on;
plot(G.x,mean(fitted'),'r--');
xlabel('Peristimulus time (secs)','FontSize',12); 
ylabel('Response','FontSize',12);
title('PSTH and Fitted Response','FontSize',16);
legend('95% Confidence Interval','PSTH','Fitted Response');

subplot(2,1,2);
spm_plot_ci(mean(fitted'),var(fitted'),G.x,[]);
xlabel('Peristimulus time (secs)','FontSize',12); 
ylabel('Response','FontSize',12);
title('Fitted Response','FontSize',16);
legend('95% Confidence Interval','Fitted Response');