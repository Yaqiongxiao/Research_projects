%% differences in connections between age 5 and age 6
% Benjamini and hochberge False discovery rate for multiple comparisons
all_FC_5yo = load(['all_FC_5/all_FC.mat']);
all_FC_6yo = load(['all_FC_6/all_FC.mat']);

con_age = [];
for i  = 1: size(all_FC_5yo.allb,2)
    [h p ci stats] = ttest(all_FC_6yo.all_fc(:,i), all_FC_5yo.allb(:,i));
    con_age (i,1) = stats.tstat; %t-value
    con_age (i,2) = p; %p-value
end

con_age_sort = con_age;
[Y, I]=sort(con_age_sort(:,2));
con_age_sort=con_age_sort(I,:);
con_age_sort (:,3) = I;

save(['network_development/con_age_sort.mat'],'con_age_sort');
     
[pthr, pcor, padj] = fdr(con_age(i,2),0.05) %FDR correction

% back to 39*39 matrix
k = 1;
for i = 1:38
    for j = i+1:39
      matrix_all (i,j) = k;
      k = k+1;
    end
end


%% correlation with all connections
gonogo_5 = load(['labels/go-no-go_5yo.txt']);
% gonogo 5 
for i = 1: size(all_FC_5yo.allb,2)
    [r p] = corrcoef(all_FC_5yo.allb(:,i),gonogo_5);
    FC_gonogo_5 (i,1) = r(1,2);
    FC_gonogo_5 (i,2)= p(1,2);
end

FC_gonogo_5_sort = FC_gonogo_5;
[Y, I]=sort(FC_gonogo_5_sort(:,2));
FC_gonogo_5_sort=FC_gonogo_5_sort(I,:);

FC_gonogo_5_sort (:,3) = I;

save(['network_development/FC_gonogo_5_sort.mat'],'FC_gonogo_5_sort');

% gonogo 6 
gonogo_6 = load(['labels/go-no-go_6yo.txt']);
for i = 1: size(all_FC_6yo.all_fc,2)
    [r p] = corrcoef(all_FC_6yo.all_fc(:,i),gonogo_6);
    FC_gonogo_6 (i,1) = r(1,2);
    FC_gonogo_6 (i,2)= p(1,2);
end

FC_gonogo_6_sort = FC_gonogo_6;
[Y, I]=sort(FC_gonogo_6_sort(:,2));
FC_gonogo_6_sort=FC_gonogo_6_sort(I,:);

FC_gonogo_6_sort (:,3) = I;

save(['network_development/FC_gonogo_6_sort.mat'],'FC_gonogo_6_sort');

%% check the connections 

[row col] =find(matrix_all == FC_gonogo_5_sort(1,3))

%% r distribution at age 5 and age 6
r_5yo = mean(all_FC_5yo.allb,1);
r_6yo = mean(all_FC_6yo.all_fc,1);
(max(mean(all_FC_5yo.allb,1)) - min(mean(all_FC_5yo.allb,1)))/0.01
(max(mean(all_FC_6yo.all_fc,1)) - min(mean(all_FC_6yo.all_fc,1)))/0.01

figure(1)
clf(1)
[nb, xb] = hist(r_5yo, 145);
bh = bar(xb, nb);
set(bh,'faceColor','b','FaceAlpha',.3,'EdgeAlpha',.3)
hold on
[nb, xb] = hist(r_6yo, 145);
bh = bar(xb, nb);
set(bh,'faceColor','r', 'FaceAlpha',.3,'EdgeAlpha',.3)
ylabel('Number of connections','FontSize',16);% y-axis label
xlabel('Correlation coefficient (r) in 0.01 bins','FontSize',16);

filename=['network_development/r_distribution'];
print(1,'-dtiff',filename);

%% degree calculation at each age 
allfiles=dir ('all_FC_5/FC/zFCMap*.txt');

clear node.deg
    for j = 1:length(allfiles)
    X=load(['all_FC_5/FC/' allfiles(j).name]);   
    
    sum_ki = zeros(42,39);
    for cost=0.1:0.01:0.50
        Adj = gretna_R2b (X, 's', cost);
%         [id,od,deg] = degrees_dir(Adj)  
        [averk ki] = gretna_node_degree(Adj);
        [net.deg(cost,j), node.deg(cost,j,:)] = gretna_node_degree(Adj);
        sum_ki (j,:) = ki +sum_ki(j,:);
        [M] = gretna_modularity(bin, '2', 0);
         net.mod(thres_j,sub) = M.modularity_real;
    end
    nodedeg(j,:) = mean(node.deg);
    mean_ki(j,:) = mean(sum_ki(j,:),2);
                % modularity
    end