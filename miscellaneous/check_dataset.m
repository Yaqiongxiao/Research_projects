% check dataset 

datadir = dir('/NOBACKUP/former_SCR2/Diffusion_data/5yo/');
allfile_touch = {'BH2K' 'EJ1K' 'GE2K' 'GL5K' 'HJ9K' 'HN2K' 'HP2K' 'JT1K' 'KL4K' 'KM5K' 'LH2K' 'ML5K' 'NL2K' 'PH1K' 'PL3K' 'RC1K' 'RT1K' 'SB2K' 'SC3K' 'SE8K' 'SM8K' 'SN4K' 'SP3K' 'TL4K' 'UE1K' 'VJ1K' 'WF1K' 'WM3K' 'WM4K' 'ZP1K'};

k = 1;
for i = 3:45
    if sum (strcmp (datadir(i).name,allfile_touch)) == 1;
    allfile_new {k} = datadir(i).name;
    k = k+1;
    end      
end

% select non-exist subjects

k = 1;
for j = 1:30
if sum (strcmp (allfile_touch{j}, allfile_new)) == 0;
 allfile_non{k} = allfile_touch{j};
 k = k+1;
end
end