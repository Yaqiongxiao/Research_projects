%% read table and choose data from specific subjects

behavior_data = readtable('vol2surf/behavior_data.csv'); 

k = 1;
for j = 3:length(allfile)
    if sum(strcmp(allfile(j).name, behavior_data.Var2))
        a = strmatch(allfile(j).name, behavior_data.Var2);
        behavior_data_new(k,:) = behavior_data(a,:);
        k = k+1;
     end
end