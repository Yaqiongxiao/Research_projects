%% check the file numbers in the folder

subject = {'BI1K' 'KE2K' 'KL1K' 'KS5K' 'PT2K' 'RB4K' 'RL6K' 'TJ1K' 'UV1K' 'VA1K' 'WF2K' 'BH2K' 'EJ1K' 'GE2K' 'GL5K' 'HJ9K' 'HN2K' 'HP2K' 'JT1K' 'KL4K' 'LH2K' 'ML5K' 'NL2K' 'PH1K' 'PL3K' 'RC1K' 'RT1K' 'SB2K' 'SC3K' 'SE8K' 'SM8K' 'SN4K' 'SP3K' 'TL4K' 'UE1K' 'VJ1K' 'WF1K' 'WM3K' 'WM4K' 'ZP1K'};

datadir = '/NOBACKUP/former_SCR2/DWI_data/5yo_touch/';
folders = {'AP_DICOM' 'PA_DICOM' 'Field_map1' 'Field_map2'};

k = 1;
for i = 1:40
    for n = 1:4
        subj_dir = dir([datadir, char(subject(i)), '/' char(folders(n)) '/00*']);
        if  (n == 1 && (length(subj_dir) ~= 67)) || (n == 2 && (length(subj_dir) ~= 132)) || (n == 3 && (length(subj_dir) ~= 66)) || (n == 4 && (length(subj_dir) ~= 33)) 
            files_un{k} = subject(i); 
       end
     k = k+1;
    end
end