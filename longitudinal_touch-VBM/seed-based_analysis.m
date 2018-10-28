% seed based analysis at both time points, based on right pSTS (51, -27, -3) and DMPFC (9, 66, 18)
GMV_5yo = ['paired-t/5yo'];
GMV_6yo = ['paired-t/6yo'];
GMV_diff = 'diff';

ROIs = {'ROI Center(mm)=(51, -27, -3); Radius=6.00 mm.'; 'ROI Center(mm)=(9, 66, 18); Radius=6.00 mm.'};

rest_ExtractROITC(GMV_5yo, ROIs,'results/5yo');
rest_ExtractROITC(GMV_6yo, ROIs,'results/6yo');
rest_ExtractROITC(GMV_diff, ROIs,'results/diff');

GMV_5yo_signal = load('results/5yo/5yo_ROISignals.txt');
GMV_6yo_signal = load('results/6yo/6yo_ROISignals.txt');
GMV_diff = load('results/diff/diff_ROISignals.txt');

mean(GMV_5yo_signal)   % 0.7562  0.5215
mean(GMV_6yo_signal)   % 0.7664   0.5345
mean(GMV_diff) 

[r p] = corrcoef(GMV_6yo_signal(:,1),GMV_5yo_signal(:,1)) % r = 0.99 p<.001

[h p ci stats] = ttest(GMV_6yo_signal(:,1),GMV_5yo_signal(:,1));  % p = 7.5728e-13  t(34) =  11.0984
[h p ci stats] = ttest(GMV_6yo_signal(:,2),GMV_5yo_signal(:,2));  % p = 1.6198e-10  t(34) =  8.9983

% correlation between GMV and behavioral performance  2016-12-01
mean(incidental_5yo)  % 1.0818
std(incidental_5yo)   % 0.9889

mean(instrumental_5yo) % 0.2086
std(instrumental_5yo)  % 0.2292

mean(total_5yo)   % 1.2903
std(total_5yo)    % 1.0629

[r p] = corrcoef(GMV_5yo_signal(:,1), incidental_6yo); % r = 0.38, p = 0.024
[r p] = corrcoef(GMV_5yo_signal(:,1), instrumental_6yo); % r = -0.15, p = 0.37
[r p] = corrcoef(GMV_5yo_signal(:,1), total_6yo); % r = 0.36, p = 0.034

[r p] = corrcoef(GMV_6yo_signal(:,1), incidental_5yo); % r = -0.25, p = 0.14
[r p] = corrcoef(GMV_6yo_signal(:,1), instrumental_5yo); % r = 0.05, p = 0.78
[r p] = corrcoef(GMV_6yo_signal(:,1), total_5yo); % r = -0.23, p = 0.19

% partial correlation
[b bint r_GMV rint] = regress(GMV_6yo_signal(:,1),GMV_5yo_signal(:,1));
[b bint r_instrumental_touch rint] = regress(instrumental_6yo,instrumental_5yo);
[b bint r_incidental_touch rint] = regress(incidental_6yo,incidental_5yo);
[b bint r_total_touch rint] = regress(total_6yo,total_5yo);

[r p] = corrcoef(r_GMV, r_instrumental_touch)  % r = 0.08  p = 0.63
[r p] = corrcoef(r_GMV, r_incidental_touch)   % r = -0.002 p = 0.99
[r p] = corrcoef(r_GMV, r_total_touch)  % r = 0.017, p = 0.92

[r p] = corrcoef(r_GMV, instrumental_6yo)  % r = 0.026, p = 0.88
[r p] = corrcoef(r_GMV, incidental_6yo) % r = -0.078, p = 0.65
[r p] = corrcoef(r_GMV, total_6yo) % r = -0.075, p = 0.67

[r p] = corrcoef(GMV_5yo_signal(:,1), r_instrumental_touch) % r = -0.17, p = 0.32
[r p] = corrcoef(GMV_5yo_signal(:,1), r_incidental_touch) % r = 0.49, p = 0.0026
[r p] = corrcoef(GMV_5yo_signal(:,1), r_total_touch) % r = 0.45 p = 0.006

[r p] = corrcoef(GMV_5yo_signal(:,1), diff_instrumental) % r = -0.134, p = 0.44
[r p] = corrcoef(GMV_5yo_signal(:,1), diff_incidental) % r = 0.49, p = 0.0026
[r p] = corrcoef(GMV_5yo_signal(:,1), diff_total) % r = 0.45 p = 0.006