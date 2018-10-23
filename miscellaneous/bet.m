function bet(dataDir)
% Bet based on FSL, initiate FSL first when using this function
% bet mean functional image and mean T1 image 

allimg = dir(dataDir,'FunImg/');

for i = 3: length(allimg)
        MeanDir=dir([datadir,'RealignParameter',filesep,allimg(i).name,filesep,'mean*.img']);
        MeanFile=[datadir,'RealignParameter',filesep,allimg(i).name,filesep,DirMean(1).name];
        OutputFile_Temp = [datadir,'RealignParameter',filesep,allimg(i).name,filesep,'Bet_',DirMean(1).name];
        %eval(['!bet ',MeanFile,' ',OutputFile_Temp,' -f 0.3'])
        y_Call_bet(MeanFile, OutputFile_Temp, '-f 0.3');
    end

for i = 3:length(allimg)
    cd([datadir,'T1Img',filesep,allimg(i).name]);
    DirImg=dir('*.img');
    T1File=[datadir,'T1Img',filesep,allimg(i).name,filesep,DirImg(1).name];
    mkdir([datadir,'T1ImgBet',filesep,allimg(i).name]);
    OutputFile_Temp = [datadir,'T1ImgBet',filesep,allimg(i).name,filesep,'Bet_',DirImg(1).name];
    %eval(['!bet ',T1File,' ',OutputFile_Temp])
    y_Call_bet(T1File, OutputFile_Temp, '');
    end