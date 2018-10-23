%% convert images to z values

allimg = dir('*ecm*');
[a b c] = rest_readfile('vistamask.nii');
for i = 1 : length(allimg)
    [q w e] = rest_readfile(allimg(i).name);
    r = zeros(size(q));
    r(a>0) = (q(a>0) - mean(mean(mean(q(a>0)))))/std(q(a>0));
    rest_writefile(r,['z',allimg(i).name(1:end-4)],size(a),b',c,'double');
end