%% check if a .dat file exists in a folder, if not, then delete the folder

datadir = '/where/is/the/directory/';
allfile = dir(datadir);

for i = 3:length(allfile)
	if ~any(size(dir([datadir, allfile(i).name,'/*.dat']),1))
    		rmdir([datadir, allfile(i).name]);
	end
end