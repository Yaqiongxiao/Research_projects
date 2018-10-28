%% hierarchical clustering analysis based on correlational matrix
% the method used in Zhang et al., 2017 (title: Cross-cultural consistency and diversity in intrinsic functional organization)
% step 1: z-score connectivity maps were averaged across all subjects.
% step 2: spatial similarities between connectivity maps were assessed by using
% Pearson correlation (r)
% step 3: transformation into the distance measure via 1-r. 
% A dendrogram was constructed based on the new distance
% matrix by using the hierarchical clustering algorithm with 'average
% linkage' in matlab. 

% the main idea is to get the distance matrix and calculate the distance
% between two points

Z = linkage(all_fc_5yo, 'average');

figure; dendrogram(Z);

c = cluster(Z,'maxclust',5);  % CLUSTER Construct clusters from a hierarchical cluster tree.

figure; dendrogram(Z);