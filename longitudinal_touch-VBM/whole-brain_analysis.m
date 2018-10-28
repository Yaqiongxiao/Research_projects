% whole brain correlation analysis at age 6  2016-08-01
GMV_6yo = {['paired-t/6yo']};

total_6yo= load(['behavioral_data/6yo_total.txt']);
incidental_6yo = load(['behavioral_data/6yo_incidental.txt']);
instrumental_6yo = load(['behavioral_data/6yo_instrumental.txt']);

y_Correlation_Image(GMV_6yo,total_6yo,'corr_total_6yo','AllResampled_GreyMask_03.nii','','');

y_Correlation_Image(GMV_6yo,incidental_6yo,'corr_incidental_6yo','AllResampled_GreyMask_03.nii','','');

y_Correlation_Image(GMV_6yo,instrumental_6yo,'corr_instrumental_6yo','AllResampled_GreyMask_03.nii','','');

[Data_Corrected ClustSize]=y_GRF_Threshold('results/corr_total_6yo',0.0214,1,0.05,'results/corr_total_6yo','','R',33); 

[Data_Corrected ClustSize]=y_GRF_Threshold('results/corr_incidental_6yo',0.0214,1,0.05,'results/corr_incidental_6yo','','R',33); 

[Data_Corrected ClustSize]=y_GRF_Threshold('results/corr_instrumental_6yo',0.0214,1,0.05,'results/corr_instrumental_6yo','','R',33); 


% whole brain correlation analysis at age 5  2016-08-01
total_5yo= load(['behavioral_data/5yo_total.txt']);
incidental_5yo = load(['behavioral_data/5yo_incidental.txt']);
instrumental_5yo = load(['behavioral_data/5yo_instrumental.txt']);

y_Correlation_Image(GMV_6yo,total_5yo,'corr_total_5yo','AllResampled_GreyMask_03.nii','','');

y_Correlation_Image(GMV_6yo,incidental_5yo,'corr_incidental_5yo','AllResampled_GreyMask_03.nii','','');

y_Correlation_Image(GMV_6yo,instrumental_5yo,'corr_instrumental_5yo','AllResampled_GreyMask_03.nii','','');

[Data_Corrected ClustSize]=y_GRF_Threshold('results/corr_total_5yo',0.0214,1,0.05,'results/corr_total_5yo','','R',33); 

[Data_Corrected ClustSize]=y_GRF_Threshold('results/corr_incidental_5yo',0.0214,1,0.05,'results/corr_incidental_5yo','','R',33); 

[Data_Corrected ClustSize]=y_GRF_Threshold('results/corr_instrumental_5yo',0.0214,1,0.05,'results/corr_instrumental_5yo','','R',33); 

